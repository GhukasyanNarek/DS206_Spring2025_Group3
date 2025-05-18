from pipeline_dimensional_data.tasks import (
    update_all_dimensions,
    update_dim_sor,
    load_all_staging_tables,
    create_staging_raw_tables,
    update_fact_orders,
    update_fact_orders_error
)
from utils import generate_execution_id
from general_logging import logger as configured_logger
from loguru import logger

class DimensionalDataFlow:
    def __init__(self):
        self.execution_id = generate_execution_id()
        self.logger = configured_logger.bind(execution_id=self.execution_id)

    def exec(self, start_date, end_date, create_staging=False):
        logger.info("ETL pipeline started.")

        if create_staging:
            logger.info("Creating staging tables...")
            create_staging_raw_tables()
            logger.info("Staging tables created.")

            logger.info("Populating staging tables from raw Excel...")
            load_all_staging_tables("raw_data_source.xlsx")
            logger.info("Staging tables populated.")

        logger.info("Updating Dim_SOR...")
        if not update_dim_sor()["success"]:
            logger.error("Aborting: update_dim_sor failed.")
            return

        logger.info("Starting update of all dimensional tables...")
        if not update_all_dimensions()["success"]:
            logger.error("Aborting: update_all_dimensions failed.")
            return

        logger.info("Updating FactOrders...")
        if not update_fact_orders()["success"]:
            logger.error("Aborting: update_fact_orders failed.")
            return

        logger.info("Updating FactOrders_Error...")
        if not update_fact_orders_error()["success"]:
            logger.error("Aborting: update_fact_orders_error failed.")
            return

        logger.info("ETL pipeline completed.")