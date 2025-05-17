from loguru import logger
from utils import generate_execution_id
import sys
import os

execution_id = generate_execution_id()

# Remove default handlers
logger.remove()

# Set default context for logs
logger.configure(extra={"execution_id": execution_id})

# Console logger (INFO and above)
logger.add(
    sys.stdout,
    level="INFO",
    colorize=True,
    format="<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <yellow>{level}</yellow> | <cyan>{file}:{function}:{line}</cyan> | <blue>{extra[execution_id]}</blue> | {message}")

# File logger (INFO and above)
logger.add(
    "logs/logs_dimensional_data_pipeline.txt",
    level="INFO",
    format="<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <yellow>{level}</yellow> | <cyan>{file}:{function}:{line}</cyan> | <blue>{extra[execution_id]}</blue> | {message}")


# File logger (DEBUG and above, basically all logs just in case we need them)
logger.add(
    "logs/all_logs.txt",
    level="TRACE", 
    format="<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <yellow>{level}</yellow> | <cyan>{file}:{function}:{line}</cyan> | <blue>{extra[execution_id]}</blue> | {message}")