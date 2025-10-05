"""
Betty Camera - Gestión de cámara con PiCamera2
"""

import logging
import io
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional

from PIL import Image, ImageDraw, ImageFont

try:
    from picamera2 import Picamera2
    PICAMERA_AVAILABLE = True
except ImportError:
    PICAMERA_AVAILABLE = False
    logging.warning("PiCamera2 no disponible - usando modo simulación")




class CameraManager:
    """Gestor de cámara Raspberry Pi con PiCamera2."""
    
    def __init__(self, config: Dict[str, Any] = None):
        self.config = config or {}
        self.logger = logging.getLogger(__name__)
        self.streaming_active = False
        
        self.default_photo_resolution = self.config.get("photo_resolution", (2592, 1944)) 
        self.streaming_resolution = self.config.get("streaming_resolution", (640, 480)) 

        self.output_dir = Path(self.config.get("output_dir", "output"))
        self.output_dir.mkdir(exist_ok=True)
        
        self._init_camera()
    
    def _init_camera(self):
        """Inicializar la cámara si está disponible."""
        if not PICAMERA_AVAILABLE:
            self.logger.warning("📸 PiCamera2 no disponible - modo simulación")
            return
        
        try:
            self.picam2 = Picamera2()
            
            self.capture_config = self.picam2.create_still_configuration(
                main={"size": self.default_photo_resolution}
            )
            
            self.preview_config = self.picam2.create_video_configuration(
                main={"size": self.streaming_resolution, "format": "RGB888"}
            )
            
            self.logger.info("📸 Cámara inicializada correctamente")
            
        except Exception as e:
            self.logger.error(f"❌ Error inicializando cámara: {e}")
            self.picam2 = None
    
    def capture_photo(self) -> Optional[bytes]:
        try:
            self.picam2.configure(self.capture_config)
            self.picam2.start()
            
            image_array = self.picam2.capture_array()
            
            self.picam2.stop()
            
            image = Image.fromarray(image_array)
            
            buffer = io.BytesIO()
            image.save(buffer, format='jpeg')
            
            return buffer.getvalue()
            
        except Exception as e:
            self.logger.error(f"❌ Error capturando foto: {e}")
            return None  

    def get_stream_frame(self) -> Optional[bytes]:
        try:
            # Iniciar preview si no está activo
            if not self.streaming_active:
                self.picam2.configure(self.preview_config)
                self.picam2.start()
                self.streaming_active = True
                self.logger.info("📺 Stream iniciado")
            
            # Capturar frame
            frame = self.picam2.capture_array()
            
            # Convertir array a PIL Image y luego a JPEG
            image = Image.fromarray(frame)
            buffer = io.BytesIO()
            image.save(buffer, format='JPEG', quality=80)
            
            return buffer.getvalue()
            
        except Exception as e:
            self.logger.error(f"❌ Error obteniendo frame de stream: {e}")
            return None
        
    def stop_streaming(self):
        """Detener el streaming de video."""
        if self.streaming_active and self.picam2:
            try:
                self.picam2.stop()
                self.streaming_active = False
                self.logger.info("📺 Stream detenido")
            except Exception as e:
                self.logger.error(f"❌ Error deteniendo stream: {e}")
    
    def cleanup(self):
        """Limpiar recursos de la cámara."""
        self.stop_streaming()
        self.logger.info("🧹 Recursos de cámara liberados")