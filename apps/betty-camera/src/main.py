#!/usr/bin/env python3
"""
Betty Camera - Aplicación FastAPI para gestión de cámara Raspberry Pi
"""

import logging
import argparse
from pathlib import Path
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Importar componentes locales
import sys
import os

# Agregar directorios al path de Python
current_dir = os.path.dirname(__file__)
sys.path.insert(0, current_dir)
sys.path.insert(0, os.path.join(current_dir, 'camera'))
sys.path.insert(0, os.path.join(current_dir, 'utils'))

# Importar módulos directamente
import camera_manager
from camera_manager import CameraManager
import routes
from routes import camera_router, config_router, init_camera_routes
import config
from config import get_config, setup_logging


# Instancia global del gestor de cámara
camera_manager = None
config = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Gestión del ciclo de vida de la aplicación."""
    global camera_manager, config
    
    # Startup
    logger.info("🚀 Iniciando Betty Camera Server...")
    
    # Cargar configuración
    config = get_config()
    camera_config = config.get_camera_config()
    
    # Inicializar gestor de cámara con configuración
    camera_manager = CameraManager(camera_config)
    
    # Inicializar rutas de cámara
    init_camera_routes(camera_manager)
    
    logger.info("✅ Betty Camera Server iniciado correctamente")
    
    yield
    
    # Shutdown
    logger.info("🛑 Deteniendo Betty Camera Server...")
    if camera_manager:
        camera_manager.cleanup()
    logger.info("✅ Betty Camera Server detenido")


# Cargar configuración inicial para el servidor
initial_config = get_config()
setup_logging(initial_config)
logger = logging.getLogger(__name__)

# Crear aplicación FastAPI
server_config = initial_config.get_server_config()
app = FastAPI(
    title="Betty Camera API",
    description="API para control de cámara Raspberry Pi con PiCamera2",
    version="1.0.0",
    lifespan=lifespan,
    debug=server_config.get("debug", False)
)

# Configurar CORS
cors_config = server_config.get("cors", {})
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_config.get("allow_origins", ["*"]),
    allow_credentials=True,
    allow_methods=cors_config.get("allow_methods", ["*"]),
    allow_headers=cors_config.get("allow_headers", ["*"]),
)

# Incluir routers
app.include_router(camera_router, prefix="/camera")

def main():
    """Función principal."""
    parser = argparse.ArgumentParser(description="Betty Camera Server")
    parser.add_argument("--host", default=None, help="Host del servidor")
    parser.add_argument("--port", type=int, default=None, help="Puerto del servidor")
    parser.add_argument("--debug", action="store_true", help="Modo debug")
    parser.add_argument("--config", help="Ruta al archivo de configuración")
    
    args = parser.parse_args()
    
    # Cargar configuración con ruta personalizada si se especifica
    config = get_config(args.config)
    server_config = config.get_server_config()
    
    # Usar argumentos de línea de comandos o configuración
    host = args.host or server_config.get("host", "0.0.0.0")
    port = args.port or server_config.get("port", 8001)
    debug_mode = args.debug or server_config.get("debug", False)
    
    logger.info(f"🍓 Betty Camera Server iniciando en {host}:{port}")
    logger.info(f"📁 Configuración cargada desde: {config.config_path}")
    
    if debug_mode:
        logger.info("🐛 Modo debug activado")
    
    import uvicorn
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug_mode,
        log_level="debug" if debug_mode else "info"
    )


if __name__ == "__main__":
    main()