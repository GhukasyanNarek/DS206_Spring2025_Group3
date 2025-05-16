from pipeline_dimensional_data.tasks import load_all_staging_tables, create_staging_raw_tables
from loguru import logger
from pipeline_dimensional_data.tasks import update_dim_categories

class DimensionalDataFlow:
    def exec(self, start_date, end_date):
        logger.info("ETL pipeline started.")
        logger.info("Ensuring staging tables exist...")

        logger.info("Ensuring staging tables exist...")
        create_staging_raw_tables()
        logger.info("Staging tables created.")
        
        # Load all staging tables at once
        result = load_all_staging_tables("raw_data_source.xlsx")
        if not result["success"]:
            logger.error("Staging load failed.")
            return

        logger.info("Finished staging load. Proceeding to dimension updates...")

        result = update_dim_categories()
        if not result["success"]:
            logger.error("Aborting: DimCategories update failed.")
            return

        logger.info("ETL pipeline completed.")