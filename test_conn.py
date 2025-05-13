from sqlalchemy import text
from utils import get_engine

if __name__ == "__main__":
    engine = get_engine()
    try:
        with engine.connect() as conn:
            result = conn.execute(text("SELECT GETDATE()"))
            print("Connected! SQL Server time:", result.fetchone()[0])
    except Exception as e:
        print("Connection failed:", e)