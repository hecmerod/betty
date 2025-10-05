"""
Rutas API para el control de la cámara
"""

from fastapi import APIRouter, HTTPException, BackgroundTasks
from fastapi.responses import StreamingResponse, FileResponse
from pathlib import Path
from typing import Dict, Any, Optional
import logging
import asyncio
import io

from camera.camera_manager import CameraManager

logger = logging.getLogger(__name__)

# Router para rutas de cámara
camera_router = APIRouter(prefix="/camera", tags=["camera"])

# Instancia global del gestor de cámara
camera_manager: Optional[CameraManager] = None


def init_camera_routes(manager: CameraManager):
    """Inicializar rutas de cámara con el gestor."""
    global camera_manager
    camera_manager = manager
    logger.info("📸 Rutas de cámara inicializadas")


@camera_router.get("/status")
async def get_camera_status() -> Dict[str, Any]:
    """Obtener estado de la cámara."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    return camera_manager.get_status()


@camera_router.post("/photo")
async def capture_photo(
    filename: Optional[str] = None,
    background_tasks: BackgroundTasks = None
) -> Dict[str, Any]:
    """Capturar una foto."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    result = camera_manager.capture_photo(filename)
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result["error"])
    
    return result


@camera_router.get("/photo/{filename}")
async def get_photo(filename: str):
    """Descargar una foto capturada."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    photo_path = camera_manager.output_dir / filename
    
    if not photo_path.exists():
        raise HTTPException(status_code=404, detail="Foto no encontrada")
    
    return FileResponse(
        path=str(photo_path),
        media_type="image/jpeg",
        filename=filename
    )


@camera_router.post("/video/start")
async def start_recording(filename: Optional[str] = None) -> Dict[str, Any]:
    """Iniciar grabación de video."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    result = camera_manager.start_video_recording(filename)
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@camera_router.post("/video/stop")
async def stop_recording() -> Dict[str, Any]:
    """Detener grabación de video."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    result = camera_manager.stop_video_recording()
    
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@camera_router.get("/video/{filename}")
async def get_video(filename: str):
    """Descargar un video grabado."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    video_path = camera_manager.output_dir / filename
    
    if not video_path.exists():
        raise HTTPException(status_code=404, detail="Video no encontrado")
    
    # Determinar el tipo MIME basado en la extensión
    media_type = "video/mp4"
    if filename.endswith(".h264"):
        media_type = "video/h264"
    
    return FileResponse(
        path=str(video_path),
        media_type=media_type,
        filename=filename
    )


def generate_stream_frames():
    """Generador de frames para streaming."""
    if not camera_manager:
        return
    
    while True:
        frame = camera_manager.get_frame_for_stream()
        if frame:
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
        else:
            # Si no hay frame, esperar un poco
            import time
            time.sleep(0.1)


@camera_router.get("/stream")
async def stream_video():
    """Stream en vivo de la cámara."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    if not camera_manager.is_available():
        # En modo simulación, también podemos hacer stream
        logger.info("📺 Iniciando stream simulado")
    else:
        logger.info("📺 Iniciando stream de cámara")
    
    return StreamingResponse(
        generate_stream_frames(),
        media_type="multipart/x-mixed-replace; boundary=frame"
    )


@camera_router.get("/files")
async def list_files() -> Dict[str, Any]:
    """Listar archivos capturados."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    try:
        output_dir = camera_manager.output_dir
        files = []
        
        if output_dir.exists():
            for file_path in output_dir.iterdir():
                if file_path.is_file():
                    stat = file_path.stat()
                    files.append({
                        "name": file_path.name,
                        "size": stat.st_size,
                        "modified": stat.st_mtime,
                        "type": "photo" if file_path.suffix.lower() in [".jpg", ".jpeg", ".png"] else "video"
                    })
        
        # Ordenar por fecha de modificación (más reciente primero)
        files.sort(key=lambda x: x["modified"], reverse=True)
        
        return {
            "files": files,
            "total": len(files),
            "output_dir": str(output_dir)
        }
        
    except Exception as e:
        logger.error(f"❌ Error listando archivos: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@camera_router.delete("/files/{filename}")
async def delete_file(filename: str) -> Dict[str, Any]:
    """Eliminar un archivo capturado."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    try:
        file_path = camera_manager.output_dir / filename
        
        if not file_path.exists():
            raise HTTPException(status_code=404, detail="Archivo no encontrado")
        
        file_path.unlink()
        logger.info(f"🗑️ Archivo eliminado: {filename}")
        
        return {
            "success": True,
            "message": f"Archivo {filename} eliminado correctamente"
        }
        
    except Exception as e:
        logger.error(f"❌ Error eliminando archivo: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# Router adicional para configuración
config_router = APIRouter(prefix="/config", tags=["config"])


@config_router.get("/resolutions")
async def get_available_resolutions() -> Dict[str, Any]:
    """Obtener resoluciones disponibles."""
    return {
        "photo_resolutions": [
            {"width": 2592, "height": 1944, "name": "Max OV5647"},
            {"width": 1920, "height": 1080, "name": "Full HD"},
            {"width": 1640, "height": 1232, "name": "HD OV5647"},
            {"width": 1280, "height": 720, "name": "HD"},
            {"width": 640, "height": 480, "name": "VGA"},
        ],
        "video_resolutions": [
            {"width": 1640, "height": 1232, "name": "HD OV5647"},
            {"width": 1280, "height": 720, "name": "HD"},
            {"width": 854, "height": 480, "name": "480p"},
            {"width": 640, "height": 480, "name": "VGA"},
        ]
    }


@config_router.get("/settings")
async def get_camera_settings() -> Dict[str, Any]:
    """Obtener configuración actual de la cámara."""
    if not camera_manager:
        raise HTTPException(status_code=500, detail="Gestor de cámara no inicializado")
    
    return {
        "photo_resolution": camera_manager.default_photo_resolution,
        "video_resolution": camera_manager.default_video_resolution,
        "output_dir": str(camera_manager.output_dir),
        "available": camera_manager.is_available(),
        "recording": camera_manager.is_recording
    }