from pipeline_dimensional_data.tasks import (create_dimensional_database,create_staging_raw_tables,should_setup_schema)
from utils import wait_until_database_exists
from loguru import logger
import argparse

def run_pipeline(reset=False):
    logger.info("Starting ORDER_DDS pipeline...")

    if reset:
        logger.info("--reset flag passed. Recreating ORDER_DDS and all tables...")
        result = create_dimensional_database()
        if not result["success"]:
            logger.error("Failed to reset ORDER_DDS database.")
            return

        if not wait_until_database_exists("ORDER_DDS", timeout=10):
            logger.error("ORDER_DDS did not become available in time.")
            return

        logger.info("ORDER_DDS is now accessible. Creating staging tables...")
        result = create_staging_raw_tables()
        if not result["success"]:
            logger.error("Failed to create staging/raw tables.")
            return

        logger.info("Schema setup complete.")
    else:
        if should_setup_schema():
            logger.error("ORDER_DDS not found. Run with --reset to create it.")
            return
        else:
            logger.info("Existing ORDER_DDS found.")

    logger.info("Pipeline is ready for data loading or ETL.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run ORDER_DDS pipeline.")
    parser.add_argument("--reset", action="store_true", help="Drop and recreate ORDER_DDS and staging tables")

    args = parser.parse_args()
    run_pipeline(reset=args.reset)