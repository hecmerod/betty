"""
Rutas API para el control de la cámara - Solo endpoint GET /camera
"""

from fastapi import APIRouter, HTTPException, Response
from fastapi.responses import StreamingResponse
from typing import Optional
import logging

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from camera_manager import CameraManager

logger = logging.getLogger(__name__)

camera_router = APIRouter(tags=["camera"])

camera_manager: Optional[CameraManager] = None


def init_camera_routes(manager: CameraManager):
    global camera_manager
    camera_manager = manager
    logger.info("📸 Rutas de cámara inicializadas")


@camera_router.get("/photo")
async def get_camera_photo():
    """Capturar y devolver una foto."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    photo_bytes = camera_manager.capture_photo()
    
    if photo_bytes is None:
        raise HTTPException(status_code=500, detail="Error capturando foto")
    
    return Response(
        content=photo_bytes,
        media_type="image/jpeg",
    )


@camera_router.get("/video")
async def get_camera_stream():
    """Stream MJPEG de la cámara."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    def generate_stream():
        """Generador de frames MJPEG."""
        while True:
            frame = camera_manager.get_stream_frame()
            if frame:
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
            else:
                # Si no hay frame, esperar un poco
                import time
                time.sleep(0.1)
    
    return StreamingResponse(
        generate_stream(),
        media_type="multipart/x-mixed-replace; boundary=frame"
    )


# Router vacío para configuración (para compatibilidad)
config_router = APIRouter(prefix="/config", tags=["config"])