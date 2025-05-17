import pyodbc
from loguru import logger
from dotenv import load_dotenv
import os
import pandas as pd
from utils import safe_date

load_dotenv()

def get_pyodbc_connection(database: str):
    """
    Creates a pyodbc connection to the specified database using .env variables.
    """
    server = os.getenv("SQL_SERVER")
    username = os.getenv("SQL_USERNAME")
    password = os.getenv("SQL_PASSWORD")
    driver = os.getenv("SQL_DRIVER", "ODBC Driver 17 for SQL Server")

    conn_str = f"DRIVER={{{driver}}};SERVER={server};DATABASE={database};UID={username};PWD={password}"
    return pyodbc.connect(conn_str, autocommit=True)

def read_sql_lines(path):
    with open(path, 'r') as f:
        lines = f.readlines()
        return [line.strip() for line in lines if line.strip() and not line.strip().startswith("--")]
    
def read_sql_file(path):
    """
    Reads the full content of a .sql file as a single string.
    """
    with open(path, 'r') as f:
        return f.read()

def execute_sql_file(db, sql_path, validate=False, validation_query=""):
    """
    Executes a SQL file against the specified database using pyodbc.
    If `validate` is True, it will validate the execution by running a validation query at the end.
    """
    try:
        logger.info(f"Connecting to {db}...")
        conn = get_pyodbc_connection(db)
        cursor = conn.cursor()

        sql = read_sql_file(sql_path)
        statements = [stmt.strip() for stmt in sql.split(";") if stmt.strip()]

        for stmt in statements:
            logger.info("Executing SQL: {}", stmt)
            try:
                cursor.execute(stmt)
            except Exception as e:
                logger.error("Execution failed: {}\nError: {}", stmt, e)
                return {"success": False, "error": str(e)}

        if validate and validation_query:
            logger.info("Running validation query...")
            cursor.execute(validation_query)
            if cursor.fetchone():
                logger.info("Validation passed.")
                return {"success": True}
            else:
                logger.error("Validation failed.")
                return {"success": False}

        logger.info("SQL file executed successfully.")
        return {"success": True}
    except Exception as e:
        logger.error("Connection or execution error: {}", e)
        return {"success": False, "error": str(e)}
    finally:
        conn.close()

def create_dimensional_database(sql_path="infrastructure_initiation/dimensional_db_creation.sql"):
    """
    Initializes ORDER_DDS by executing the given SQL file in the master database.
    """
    return execute_sql_file(
        db="master",
        sql_path=sql_path,
        validate=True,
        validation_query="SELECT name FROM sys.databases WHERE name = 'ORDER_DDS'"
    )

def create_staging_raw_tables(sql_path="infrastructure_initiation/staging_raw_table_creation.sql"):
    """
    Creates staging/raw tables inside ORDER_DDS using a clean SQL file.
    """
    return execute_sql_file(
        db="ORDER_DDS",
        sql_path=sql_path
    )

def create_dimensional_tables(sql_path="infrastructure_initiation/dimensional_db_table_creation.sql"):
    """
    Create all dimensional tables including Dim_SOR and DimProducts_History.
    """
    return execute_sql_file(
        db="ORDER_DDS",
        sql_path=sql_path
    )


def load_staging_categories(file_path: str) -> dict:
    """
    Load categories from Excel into Staging_Categories.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="Categories") 
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        for _, row in df.iterrows():
            try:
                cursor.execute("""
                    INSERT INTO dbo.Staging_Categories (CategoryID, CategoryName, Description)
                    VALUES (?, ?, ?)
                """, int(row["CategoryID"]), str(row["CategoryName"]), str(row["Description"]))
                inserted += 1
            except Exception as e:
                logger.warning("Skipping CategoryID {} due to error: {}", row["CategoryID"], e)
                skipped += 1

        conn.commit()
        logger.info("Staging_Categories: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}

    except Exception as e:
        logger.error("Failed to load categories: {}", e)
        return {"success": False, "error": str(e)}    


def update_dim_categories():
    """
    Execute the SCD1 + delete update for DimCategories.
    """
    try:
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()

        with open("pipeline_dimensional_data/queries/update_dim_categories.sql", "r") as file:
            sql_commands = file.read().split("GO")
        for cmd in sql_commands:
            if cmd.strip():
                cursor.execute(cmd)

        conn.commit()
        conn.close()
        logger.info("Updated DimCategories_SCD1 successfully.")
        return {"success": True}

    except Exception as e:
        logger.error("Failed to update DimCategories_SCD1: {}", e)
        return {"success": False, "error": str(e)}
    

def load_staging_products(file_path: str) -> dict:
    """"
    Load products from Excel into Staging_Products.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="Products")
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        for _, row in df.iterrows():
            try:
                cursor.execute("""INSERT INTO dbo.Staging_Products (ProductID, ProductName, SupplierID, CategoryID,
                        QuantityPerUnit, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""", *row) 
                inserted += 1
            except Exception as e:
                logger.warning("Skipping ProductID {} due to error: {}", row["ProductID"], e)
                skipped += 1

        conn.commit()
        logger.info("Staging_Products: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}
    except Exception as e:
        logger.error("Failed to load products: {}", e)
        return {"success": False, "error": str(e)}
    
def load_staging_orders(file_path: str) -> dict:
    """
    Load orders from Excel into Staging_Orders.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="Orders")
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        for _, row in df.iterrows():
            try:
                cursor.execute("""INSERT INTO dbo.Staging_Orders (OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate,
                        ShippedDate, ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion,
                        ShipPostalCode, ShipCountry, TerritoryID)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, str(row["OrderID"]), str(row["CustomerID"]), int(row["EmployeeID"]),
                safe_date(str(row["OrderDate"])), str(row["RequiredDate"]), safe_date(str(row["ShippedDate"])),
                int(row["ShipVia"]), float(row["Freight"]), str(row["ShipName"]),
                str(row["ShipAddress"]), str(row["ShipCity"]), str(row["ShipRegion"]),
                str(row["ShipPostalCode"]), str(row["ShipCountry"]), int(row["TerritoryID"]))
                inserted += 1
            except Exception as e:
                logger.warning("Skipping OrderID {} due to error: {}", row["OrderID"], e)
                skipped += 1
        conn.commit()
        logger.info("Staging_Orders: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}
    except Exception as e:
        logger.error("Failed to load orders: {}", e)
        return {"success": False, "error": str(e)}

def load_staging_orderdetails(file_path: str) -> dict:
    """
    Load order details from Excel into Staging_OrderDetails.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="OrderDetails")
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        df["OrderID"] = df["OrderID"].astype(int)
        for _, row in df.iterrows():
            try:
                cursor.execute("""
                    INSERT INTO dbo.Staging_OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
                    VALUES (?, ?, ?, ?, ?)
                """, *row)
                inserted += 1
            except Exception as e:
                logger.warning("Skipping OrderID {} due to error: {}", row["OrderID"], e)
                skipped += 1

        conn.commit()
        logger.info("Staging_OrderDetails: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}
    except Exception as e:
        logger.error("Failed to load order details: {}", e)
        return {"success": False, "error": str(e)}


def load_staging_shippers(file_path: str) -> dict:
    """
    Load shippers from Excel into Staging_Shippers.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="Shippers")
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        for _, row in df.iterrows():
            try:
                cursor.execute("""
                    INSERT INTO dbo.Staging_Shippers (ShipperID, CompanyName, Phone)
                    VALUES (?, ?, ?)
                """, *row)
                inserted += 1
            except Exception as e:
                logger.warning("Skipping ShipperID {} due to error: {}", row["ShipperID"], e)
                skipped += 1

        conn.commit()
        logger.info("Staging_Shippers: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}
    except Exception as e:
        logger.error("Failed to load shippers: {}", e)
        return {"success": False, "error": str(e)}


def load_staging_suppliers(file_path: str) -> dict:
    """
    Load suppliers from Excel into Staging_Suppliers.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="Suppliers")
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        for _, row in df.iterrows():
            try:
                cursor.execute("""
                    INSERT INTO dbo.Staging_Suppliers (SupplierID, CompanyName, ContactName, ContactTitle,
                        Address, City, Region, PostalCode, Country, Phone, Fax, HomePage)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, 
                    int(row["SupplierID"]), str(row["CompanyName"]), str(row["ContactName"]),
                    str(row["ContactTitle"]), str(row["Address"]), str(row["City"]), str(row["Region"]),
                    str(row["PostalCode"]), str(row["Country"]), str(row["Phone"]),
                    str(row["Fax"]), str(row["HomePage"])
                )
                inserted += 1
            except Exception as e:
                logger.warning("Skipping SupplierID {} due to error: {}", row["SupplierID"], e)
                skipped += 1

        conn.commit()
        logger.info("Staging_Suppliers: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}
    except Exception as e:
        logger.error("Failed to load suppliers: {}", e)
        return {"success": False, "error": str(e)}


def load_staging_region(file_path: str) -> dict:
    """
    Load regions from Excel into Staging_Region.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="Region")
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        for _, row in df.iterrows():
            try:
                cursor.execute("""
                    INSERT INTO dbo.Staging_Region (RegionID, RegionDescription, RegionCategory, RegionImportance)
                    VALUES (?, ?, ?, ?)
                """, *row)
                inserted += 1
            except Exception as e:
                logger.warning("Skipping RegionID {} due to error: {}", row["RegionID"], e)
                skipped += 1

        conn.commit()
        logger.info("Staging_Region: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}
    except Exception as e:
        logger.error("Failed to load region: {}", e)
        return {"success": False, "error": str(e)}


def load_staging_territories(file_path: str) -> dict:
    """
    Load territories from Excel into Staging_Territories.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="Territories")
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        for _, row in df.iterrows():
            try:
                cursor.execute("""
                    INSERT INTO dbo.Staging_Territories (TerritoryID, TerritoryDescription, TerritoryCode, RegionID)
                    VALUES (?, ?, ?, ?)
                """, *row)
                inserted += 1
            except Exception as e:
                logger.warning("Skipping TerritoryID {} due to error: {}", row["TerritoryID"], e)
                skipped += 1

        conn.commit()
        logger.info("Staging_Territories: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}
    except Exception as e:
        logger.error("Failed to load territories: {}", e)
        return {"success": False, "error": str(e)}

def load_staging_customers(file_path: str) -> dict:
    """
    Load customers from Excel into Staging_Customers.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="Customers")
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        for _, row in df.iterrows():
            try:
                cursor.execute("""
                    INSERT INTO dbo.Staging_Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address,
                        City, Region, PostalCode, Country, Phone, Fax)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,     str(row["CustomerID"]),str(row["CompanyName"]), 
                str(row["ContactName"]),str(row["ContactTitle"]),
                str(row["Address"]),str(row["City"]),str(row["Region"]),
                str(row["PostalCode"]),str(row["Country"]),
                str(row["Phone"]) if not pd.isna(row["Phone"]) else None,
                str(row["Fax"]) if not pd.isna(row["Fax"]) else None)
                inserted += 1
            except Exception as e:
                logger.warning("Skipping CustomerID {} due to error: {}", row["CustomerID"], e)
                skipped += 1

        conn.commit()
        logger.info("Staging_Customers: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}
    except Exception as e:
        logger.error("Failed to load customers: {}", e)
        return {"success": False, "error": str(e)}

def load_staging_employees(file_path: str) -> dict:
    """
    Load employees from Excel into Staging_Employees.
    """
    try:
        df = pd.read_excel(file_path, sheet_name="Employees")
        conn = get_pyodbc_connection("ORDER_DDS")
        cursor = conn.cursor()
        inserted, skipped = 0, 0

        df["ReportsTo"] = pd.to_numeric(df["ReportsTo"], errors="coerce")
        valid_reports_to = df["EmployeeID"].unique()
        df["ReportsTo"] = df["ReportsTo"].where(
        df["ReportsTo"].isin(valid_reports_to), None)
        df = df.sort_values(by="ReportsTo", na_position="first")
        columns = [
            "EmployeeID", "LastName", "FirstName", "Title", "TitleOfCourtesy",
            "BirthDate", "HireDate", "Address", "City", "Region", "PostalCode",
            "Country", "HomePhone", "Extension", "Notes", "ReportsTo", "PhotoPath"
        ]
        df = df[columns]
        for _, row in df.iterrows():
            try:
                row_data = tuple([val if pd.notnull(val) else None for val in row])
                cursor.execute("""
                    INSERT INTO dbo.Staging_Employees (
                        EmployeeID, LastName, FirstName, Title, TitleOfCourtesy,
                        BirthDate, HireDate, Address, City, Region, PostalCode, Country,
                        HomePhone, Extension, Notes, ReportsTo, PhotoPath
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""", row_data)
                inserted += 1
            except Exception as e:
                logger.warning("Skipping EmployeeID {} due to error: {}", row["EmployeeID"], e)
                skipped += 1
        conn.commit()
        logger.info("Staging_Employees: {} inserted, {} skipped", inserted, skipped)
        return {"success": True, "inserted": inserted}
    except Exception as e:
        logger.error("Failed to load employees: {}", e)
        return {"success": False, "error": str(e)}

def load_all_staging_tables(file_path: str) -> dict:
    loaders = [
        load_staging_categories,
        load_staging_customers,
        load_staging_suppliers,
        load_staging_employees,
        load_staging_products,
        load_staging_shippers,
        load_staging_territories,
        load_staging_orders,
        load_staging_orderdetails,
        load_staging_region
    ]

    for loader in loaders:
        result = loader(file_path)
        if not result.get("success"):
            logger.error("Aborting staging: {} failed", loader.__name__)
            return result

    return {"success": True}

def should_setup_schema():
    try:
        conn = get_pyodbc_connection("master")
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM sys.databases WHERE name = 'ORDER_DDS'")
        return cursor.fetchone() is None
    except Exception as e:
        logger.error("Error checking ORDER_DDS existence: {}", e)
        return False
    finally:
        conn.close()