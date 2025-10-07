#!/usr/bin/env python3
"""
Betty Camera - Aplicación FastAPI para gestión de cámara Raspberry Pi
"""

import argparse
import uvicorn
from contextlib import asynccontextmanager
import os
from pathlib import Path

from fastapi import FastAPI

import sys

current_dir = os.path.dirname(__file__)
sys.path.insert(0, current_dir)
sys.path.insert(0, os.path.join(current_dir, 'camera'))

from camera.camera_manager import CameraManager
from camera.routes import camera_router, init_camera_routes
from logger import setup_logging, get_logger

def load_env():
    """Cargar variables de entorno desde archivo .env"""
    env_path = Path(__file__).parent.parent / ".env"
    if env_path.exists():
        with open(env_path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#'):
                    key, value = line.split('=', 1)
                    os.environ[key.strip()] = value.strip()

load_env()

logger = setup_logging(level=os.getenv("LOG_LEVEL", "INFO"))

camera_manager = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global camera_manager
    
    camera_manager = CameraManager()    
    init_camera_routes(camera_manager)
    
    logger.info("✅ Betty Camera Server iniciado correctamente")
    
    yield
    
    logger.info("🛑 Deteniendo Betty Camera Server...")
    if camera_manager:
        camera_manager.cleanup()


app = FastAPI(
    title="Betty Camera API",
    lifespan=lifespan,
)

app.include_router(camera_router, prefix="/camera")

if __name__ == "__main__":
    reload = os.getenv("DEV_MODE", "False").lower() in ("true", "1", "t")
    print(reload)
    uvicorn.run(
        "main:app",
        host=os.getenv("HOST"),
        port=int(os.getenv("PORT")),
        reload=reload,
    )