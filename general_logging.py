from loguru import logger
from utils import generate_execution_id
logger.configure(extra={"execution_id": generate_execution_id()})

logger.add(
    "logs/logs_dimensional_data_pipeline.txt",
    format="{time:YYYY-MM-DD HH:mm:ss} | {level} | {extra[execution_id]} | {message}"
)

