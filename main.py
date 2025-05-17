from pipeline_dimensional_data.tasks import (
    create_dimensional_database,
    create_staging_raw_tables,
    should_setup_schema,
    create_dimensional_tables,
)
from pipeline_dimensional_data.flow import DimensionalDataFlow
from utils import wait_until_database_exists
from loguru import logger
import argparse
import datetime
from pipeline_dimensional_data.config import DEFAULT_START_DATE, DEFAULT_END_DATE

def run_pipeline(reset=False, load_staging=False, create_staging=False, start_date=None, end_date=None):
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

        logger.info("ORDER_DDS available. Creating dimensional tables...")
        result = create_dimensional_tables()
        if not result["success"]:
            logger.error("Failed to create dimensional tables.")
            return

        logger.info("Schema setup complete.")
    else:
        if should_setup_schema():
            logger.error("ORDER_DDS not found. Run with --reset to create it.")
            return
        else:
            logger.info("Existing ORDER_DDS found.")

    logger.info("Pipeline is ready. Launching ETL flow...")
    flow = DimensionalDataFlow()
    flow.exec(
        start_date=start_date,
        end_date=end_date,
        load_staging=load_staging,
        create_staging=create_staging
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run ORDER_DDS pipeline.")
    parser.add_argument("--reset", action="store_true", help="Drop and recreate ORDER_DDS and staging tables")
    parser.add_argument("--start_date", type=str, help="Start date for incremental load (YYYY-MM-DD)")
    parser.add_argument("--end_date", type=str, help="End date for incremental load (YYYY-MM-DD)")
    parser.add_argument("--load-staging", action="store_true", help="Reload raw Excel data into staging tables")

    args = parser.parse_args()

    start_date = args.start_date or DEFAULT_START_DATE
    end_date = args.end_date or datetime.date.today().isoformat()

    run_pipeline(
        reset=args.reset,
        load_staging=args.load_staging or args.reset,
        create_staging=args.reset,  
        start_date=start_date,
        end_date=end_date
    )