import pyodbc
from loguru import logger
from dotenv import load_dotenv
import os

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