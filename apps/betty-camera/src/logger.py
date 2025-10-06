"""
Configuración de logging para Betty Camera
"""

import logging
import sys

# Códigos de color ANSI
COLORS = {
    'DEBUG': '\033[36m',    # Cyan
    'INFO': '\033[92m',     # Verde brillante
    'WARNING': '\033[93m',  # Amarillo
    'ERROR': '\033[91m',    # Rojo
    'CRITICAL': '\033[95m', # Magenta
}
RESET = '\033[0m'  # Reset color

class ColoredFormatter(logging.Formatter):
    """Formatter que añade colores ANSI al log."""
    def format(self, record):
        color = COLORS.get(record.levelname, '')
        colored_levelname = f'{color}{record.levelname}{RESET}'
        
        original_levelname = record.levelname
        record.levelname = colored_levelname
        
        formatted = super().format(record)
        
        record.levelname = original_levelname
        
        return formatted

def setup_logging(level: str = "INFO") -> logging.Logger:
    log_format = '%(levelname)s - %(message)s'
    
    log_level = getattr(logging, level.upper(), logging.INFO)
    
    logging.getLogger().handlers.clear()
    
    handler = logging.StreamHandler(sys.stdout)
    formatter = ColoredFormatter(log_format)
    handler.setFormatter(formatter)
    
    logging.basicConfig(
        level=log_level,
        handlers=[handler],
        force=True 
    )
    
    logger = logging.getLogger("betty_camera")
    logger.setLevel(log_level)
    
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("asyncio").setLevel(logging.WARNING)
    
    return logger

def get_logger() -> logging.Logger:
    return logging.getLogger("betty_camera")