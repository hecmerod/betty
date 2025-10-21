#!/usr/bin/env python3
import os
import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI
import sys

current_dir = os.path.dirname(__file__)
sys.path.insert(0, current_dir)

from config.env_loader import load_env
from config.settings import settings
from infrastructure.config.dependencies import get_container
from presentation.routes.health_routes import health_router
from presentation.routes.camera_routes import camera_router
from logger import setup_logging


load_env()
logger = setup_logging(level=settings.LOG_LEVEL)


@asynccontextmanager
async def lifespan(app: FastAPI):
    container = get_container()
    container.camera_adapter.start()
    container.detection_service.start()
    
    logger.info("✅ Betty Camera Server iniciado correctamente")
    logger.info(f"📍 Servidor escuchando en {settings.HOST}:{settings.PORT}")
    
    yield
    
    logger.info("🛑 Deteniendo Betty Camera Server...")
    container.detection_service.stop()
    container.camera_adapter.stop()


app = FastAPI(
    title="Betty Camera API",
    version="1.0.0",
    lifespan=lifespan,
)

app.include_router(health_router)
app.include_router(camera_router, prefix="/camera")


if __name__ == "__main__":
    reload = os.getenv("DEV_MODE", "False").lower() in ("true", "1", "t")
    
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=reload,
    )
