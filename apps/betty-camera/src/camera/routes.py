"""
Rutas API para el control de la cámara - Solo endpoint GET /camera
"""

from fastapi import APIRouter, Response
from fastapi.responses import StreamingResponse
from typing import Optional

import json  
import time

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from camera_manager import CameraManager
from logger import get_logger

logger = get_logger()

camera_router = APIRouter(tags=["camera"])

camera_manager: Optional[CameraManager] = None


def init_camera_routes(manager: CameraManager):
    global camera_manager
    camera_manager = manager
    logger.info("📸 Rutas de cámara inicializadas")


@camera_router.get("/photo")
async def get_camera_photo():    
    photo_bytes = camera_manager.get_current_frame()

    return Response(
        content=photo_bytes,
        media_type="image/jpeg",
    )


@camera_router.get("/video")
async def get_camera_stream(): 
    def generate_stream():
        start_time = time.time()
        timeout = 30
        timeout_json = json.dumps({"connectionReseted": True})
        
        logger.info("🎬 Iniciando stream de video")
        
        while time.time() - start_time < timeout:
            frame = camera_manager.get_current_frame()
            if frame:
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
        
        yield (b'--frame\r\n'
               b'Content-Type: application/json\r\n\r\n' + timeout_json.encode() + b'\r\n')
    
    return StreamingResponse(
        generate_stream(),
        media_type="multipart/x-mixed-replace; boundary=frame"
    )