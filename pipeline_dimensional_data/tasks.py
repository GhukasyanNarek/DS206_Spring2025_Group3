from utils import get_engine, read_sql_file

def create_dimensional_database(sql_path="infrastructure_initiation/dimensional_db_creation.sql"):
    """
    Create dimensional tables in the database.
    """
    engine = get_engine()
    query = read_sql_file(sql_path)
    conn = engine.raw_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(query)
        cursor.commit()
        print("Dimensional tables created successfully.")
        return {"success": True}
    except Exception as e:
        print("Error creating dimensional tables:", e)
        return {"success": False, "error": str(e)}        