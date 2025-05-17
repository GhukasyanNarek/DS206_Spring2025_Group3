"""
Configuration for dimensional data warehouse tables and database settings.
"""

# Database Configuration
DATABASE_NAME = "ORDER_DDS"
SCHEMA_NAME = "dbo"

# Dimension Tables Configuration
DIM_SOR = "Dim_SOR"
DIM_CATEGORIES_SCD1 = "DimCategories_SCD1"
DIM_CUSTOMERS_SCD2 = "DimCustomers_SCD2"
DIM_EMPLOYEES_SCD1 = "DimEmployees_SCD1"
DIM_SUPPLIERS_SCD4 = "DimSuppliers_SCD4"
DIM_PRODUCTS_SCD4 = "DimProducts_SCD4"
DIM_PRODUCTS_HISTORY = "DimProducts_History"
DIM_REGION_SCD1 = "DimRegion_SCD1"
DIM_SHIPPERS_SCD3 = "DimShippers_SCD3"
DIM_SUPPLIERS_HISTORY = "DimSuppliers_History"
DIM_TERRITORIES_SCD3 = "DimTerritories_SCD3"

# Fact Table Configuration
FACT_ORDERS = "FactOrders"

# SOR Configuration
SOR_STAGING_TABLES = {
    "Categories": "Staging_Categories",
    "Customers": "Staging_Customers",
    "Employees": "Staging_Employees",
    "Products": "Staging_Products",
    "Suppliers": "Staging_Suppliers",
    "Region": "Staging_Region",
    "Shippers": "Staging_Shippers",
    "Territories": "Staging_Territories"
}

# Time Parameters
DEFAULT_START_DATE = "2000-01-01"
DEFAULT_END_DATE = "9999-12-31"

# Database metadata
DATABASE_CONFIG = {
    "driver": "ODBC Driver 17 for SQL Server",
    "port": 1433,
    "default_schema": "dbo"
}