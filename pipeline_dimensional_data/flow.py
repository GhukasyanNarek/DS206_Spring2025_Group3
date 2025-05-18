from pipeline_dimensional_data.tasks import (
    update_dim_categories, update_dim_employees, update_dim_sor,
    load_all_staging_tables, create_staging_raw_tables, update_dim_regions, update_dim_customers)
from utils import generate_execution_id
from general_logging import logger as configured_logger
from loguru import logger

class DimensionalDataFlow:
    def __init__(self):
        self.execution_id = generate_execution_id()
        configured_logger.bind(execution_id=self.execution_id)

    def exec(self, start_date, end_date, create_staging=False):
        logger.info("ETL pipeline started.")
        if create_staging:
            logger.info("Creating staging tables...")
            create_staging_raw_tables()
            logger.info("Staging tables created.")
            logger.info("Populating staging tables from raw Excel...")
            load_all_staging_tables("raw_data_source.xlsx")
        else:
            logger.info("Skipping staging table creation and load (no --reset passed).")

        logger.info("Updating Dim_SOR...")
        if not update_dim_sor()["success"]:
            logger.error("Aborting: update_dim_sor failed.")
            return

        logger.info("Updating DimCategories...")
        if not update_dim_categories()["success"]:
            logger.error("Aborting: update_dim_categories failed.")
            return

        logger.info("Updating DimEmployees...")
        if not update_dim_employees()["success"]:
            logger.error("Aborting: update_dim_employees failed.")
            return
        
        logger.info("Updating DimRegions...")
        if not update_dim_regions()["success"]:
            logger.error("Aborting: update_dim_regions failed.")
            return
        
        logger.info("Updating DimCustomers...")
        if not update_dim_customers()["success"]:
            logger.error("Aborting: update_dim_customers failed.")
            return

    logger.info("ETL pipeline completed.")