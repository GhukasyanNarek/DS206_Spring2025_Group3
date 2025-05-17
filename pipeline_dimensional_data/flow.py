from pipeline_dimensional_data.tasks import (
    load_all_staging_tables,
    create_staging_raw_tables,
    update_dim_categories,
    update_dim_customers,
    update_dim_employees,
    update_dim_suppliers,
    update_dim_products,
    update_dim_region,
    update_dim_shippers,
    update_dim_territories,
    update_fact_orders 
)

from loguru import logger

class DimensionalDataFlow:
    def exec(self, start_date, end_date):
        logger.info("ETL pipeline started.")
        create_staging_raw_tables()

        result = load_all_staging_tables("raw_data_source.xlsx")
        if not result["success"]:
            logger.error("Staging load failed.")
            return

        logger.info("Staging load completed. Updating dimensions...")

        for update_func in [
            update_dim_categories,
            update_dim_customers,
            update_dim_employees,
            update_dim_suppliers,
            update_dim_products,
            update_dim_region,
            update_dim_shippers,
            update_dim_territories
        ]:
            result = update_func()
            if not result["success"]:
                logger.error("Aborting: {} failed.".format(update_func.__name__))
                return

        logger.info("Dimension updates complete. Updating fact table...")
        result = update_fact_orders()
        if not result["success"]:
            logger.error("FactOrders update failed.")
            return

        logger.info("ETL pipeline completed.")
