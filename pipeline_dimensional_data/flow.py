from pipeline_dimensional_data.tasks import (load_all_staging_tables, create_staging_raw_tables, update_dim_categories)
from loguru import logger
from utils import generate_execution_id
from general_logging import logger as configured_logger

class DimensionalDataFlow:
    def __init__(self):
        self.execution_id = generate_execution_id()
        configured_logger.bind(execution_id=self.execution_id)

    def exec(self, start_date, end_date, load_staging=False, create_staging=False):
        logger.info("ETL pipeline started.")

        if create_staging:
            logger.info("Ensuring staging tables exist...")
            create_staging_raw_tables()
            logger.info("Staging tables created.")
        else:
            logger.info("Skipping staging table creation (create_staging=False).")

        if load_staging:
            logger.info("Reloading staging tables from raw_data_source.xlsx...")
            load_all_staging_tables("raw_data_source.xlsx")
        else:
            logger.info("Skipping staging data load (--load-staging is not passed).")

        logger.info("Proceeding to dimension updates...")

        result = update_dim_categories()
        if not result["success"]:
            logger.error("Aborting: DimCategories update failed.")
            return
        
        result = update_dim_categories()
        if not result["success"]:
            logger.error("Aborting: DimCategories update failed.")
            return

        logger.info("ETL pipeline completed.")