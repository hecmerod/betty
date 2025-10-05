"""
Betty Camera - Gestión de cámara con PiCamera2
"""

import logging
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, Tuple
import threading
import io

try:
    from picamera2 import Picamera2
    from picamera2.encoders import H264Encoder, JpegEncoder
    from picamera2.outputs import FileOutput, CircularOutput
    PICAMERA_AVAILABLE = True
except ImportError:
    PICAMERA_AVAILABLE = False
    logging.warning("PiCamera2 no disponible - usando modo simulación")

try:
    import cv2
    OPENCV_AVAILABLE = True
except ImportError:
    OPENCV_AVAILABLE = False
    logging.warning("OpenCV no disponible - usando PIL para imágenes simuladas")

import numpy as np
from PIL import Image, ImageDraw, ImageFont


class CameraManager:
    """Gestor de cámara Raspberry Pi con PiCamera2."""
    
    def __init__(self, config: Dict[str, Any] = None):
        self.config = config or {}
        self.logger = logging.getLogger(__name__)
        self.picam2 = None
        self.is_recording = False
        self.recording_thread = None
        self.preview_config = None
        self.capture_config = None
        
        # Configuración por defecto (optimizada para OV5647)
        self.default_photo_resolution = self.config.get("photo_resolution", (2592, 1944))  # Máxima resolución OV5647
        self.default_video_resolution = self.config.get("video_resolution", (1640, 1232))   # HD optimizado para OV5647
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
            
            # Configuración de preview (para stream)
            self.preview_config = self.picam2.create_preview_configuration(
                main={"size": (640, 480), "format": "RGB888"}
            )
            
            # Configuración de captura (para fotos)
            self.capture_config = self.picam2.create_still_configuration(
                main={"size": self.default_photo_resolution}
            )
            
            self.logger.info("📸 Cámara inicializada correctamente")
            
        except Exception as e:
            self.logger.error(f"❌ Error inicializando cámara: {e}")
            self.picam2 = None
    
    def is_available(self) -> bool:
        """Verificar si la cámara está disponible."""
        return PICAMERA_AVAILABLE and self.picam2 is not None
    
    def get_timestamp(self) -> str:
        """Obtener timestamp actual."""
        return datetime.now().isoformat()
    
    def get_status(self) -> Dict[str, Any]:
        """Obtener estado de la cámara."""
        return {
            "available": self.is_available(),
            "recording": self.is_recording,
            "timestamp": self.get_timestamp(),
            "config": {
                "photo_resolution": self.default_photo_resolution,
                "video_resolution": self.default_video_resolution,
                "output_dir": str(self.output_dir)
            }
        }
    
    def capture_photo(self, filename: str = None) -> Dict[str, Any]:
        """Capturar una foto."""
        if not self.is_available():
            # Modo simulación
            return self._simulate_photo_capture(filename)
        
        try:
            if filename is None:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"photo_{timestamp}.jpg"
            
            photo_path = self.output_dir / filename
            
            # Configurar para captura
            self.picam2.configure(self.capture_config)
            self.picam2.start()
            
            # Capturar foto
            self.picam2.capture_file(str(photo_path))
            
            self.picam2.stop()
            
            self.logger.info(f"📸 Foto capturada: {photo_path}")
            
            return {
                "success": True,
                "filename": filename,
                "path": str(photo_path),
                "size": photo_path.stat().st_size,
                "timestamp": self.get_timestamp()
            }
            
        except Exception as e:
            self.logger.error(f"❌ Error capturando foto: {e}")
            return {
                "success": False,
                "error": str(e),
                "timestamp": self.get_timestamp()
            }
    
    def _simulate_photo_capture(self, filename: str = None) -> Dict[str, Any]:
        """Simular captura de foto para testing."""
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"photo_sim_{timestamp}.jpg"
        
        photo_path = self.output_dir / filename
        
        # Crear imagen simulada con PIL
        img = Image.new('RGB', (640, 480), color=(50, 50, 50))
        draw = ImageDraw.Draw(img)
        
        # Agregar texto
        try:
            # Intentar cargar una fuente
            font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 32)
            font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 20)
        except:
            # Usar fuente por defecto si no se encuentra
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()
        
        # Texto principal
        draw.text((50, 200), "BETTY CAMERA SIM", fill=(255, 255, 255), font=font_large)
        draw.text((50, 250), datetime.now().strftime("%Y-%m-%d %H:%M:%S"), 
                 fill=(255, 255, 255), font=font_small)
        draw.text((50, 300), f"Archivo: {filename}", fill=(200, 200, 200), font=font_small)
        
        # Guardar imagen
        img.save(str(photo_path), "JPEG", quality=85)
        
        self.logger.info(f"📸 Foto simulada: {photo_path}")
        
        return {
            "success": True,
            "filename": filename,
            "path": str(photo_path),
            "size": photo_path.stat().st_size,
            "timestamp": self.get_timestamp(),
            "simulation": True
        }
    
    def start_video_recording(self, filename: str = None) -> Dict[str, Any]:
        """Iniciar grabación de video."""
        if self.is_recording:
            return {
                "success": False,
                "error": "Ya se está grabando video",
                "timestamp": self.get_timestamp()
            }
        
        if not self.is_available():
            return self._simulate_video_recording(filename)
        
        try:
            if filename is None:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"video_{timestamp}.h264"
            
            video_path = self.output_dir / filename
            
            # Configurar para video
            video_config = self.picam2.create_video_configuration(
                main={"size": self.default_video_resolution}
            )
            self.picam2.configure(video_config)
            
            encoder = H264Encoder(bitrate=10000000)
            output = FileOutput(str(video_path))
            
            self.picam2.start_recording(encoder, output)
            self.is_recording = True
            
            self.logger.info(f"🎥 Grabación iniciada: {video_path}")
            
            return {
                "success": True,
                "filename": filename,
                "path": str(video_path),
                "timestamp": self.get_timestamp()
            }
            
        except Exception as e:
            self.logger.error(f"❌ Error iniciando grabación: {e}")
            return {
                "success": False,
                "error": str(e),
                "timestamp": self.get_timestamp()
            }
    
    def stop_video_recording(self) -> Dict[str, Any]:
        """Detener grabación de video."""
        if not self.is_recording:
            return {
                "success": False,
                "error": "No se está grabando video",
                "timestamp": self.get_timestamp()
            }
        
        try:
            if self.is_available():
                self.picam2.stop_recording()
            
            self.is_recording = False
            self.logger.info("🛑 Grabación detenida")
            
            return {
                "success": True,
                "message": "Grabación detenida",
                "timestamp": self.get_timestamp()
            }
            
        except Exception as e:
            self.logger.error(f"❌ Error deteniendo grabación: {e}")
            return {
                "success": False,
                "error": str(e),
                "timestamp": self.get_timestamp()
            }
    
    def _simulate_video_recording(self, filename: str = None) -> Dict[str, Any]:
        """Simular grabación de video."""
        if filename is None:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"video_sim_{timestamp}.mp4"
        
        self.is_recording = True
        self.logger.info(f"🎥 Grabación simulada iniciada: {filename}")
        
        return {
            "success": True,
            "filename": filename,
            "simulation": True,
            "timestamp": self.get_timestamp()
        }
    
    def get_frame_for_stream(self) -> Optional[bytes]:
        """Obtener frame para streaming."""
        if not self.is_available():
            return self._generate_simulation_frame()
        
        try:
            # Configurar para preview si no está configurado
            if not self.picam2.started:
                self.picam2.configure(self.preview_config)
                self.picam2.start()
            
            # Capturar frame
            frame = self.picam2.capture_array()
            
            # Convertir a JPEG
            img = Image.fromarray(frame)
            buffer = io.BytesIO()
            img.save(buffer, format='JPEG', quality=85)
            return buffer.getvalue()
            
        except Exception as e:
            self.logger.error(f"❌ Error obteniendo frame: {e}")
            return None
    
    def _generate_simulation_frame(self) -> bytes:
        """Generar frame simulado para streaming."""
        # Crear imagen simulada con PIL
        img = Image.new('RGB', (640, 480), color=(0, 50, 0))
        draw = ImageDraw.Draw(img)
        
        try:
            font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 28)
            font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
        except:
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()
        
        # Texto de streaming
        draw.text((100, 200), "BETTY CAMERA STREAM", fill=(0, 255, 0), font=font_large)
        draw.text((200, 250), datetime.now().strftime("%H:%M:%S"), 
                 fill=(0, 255, 0), font=font_small)
        draw.text((150, 300), "🔴 LIVE", fill=(255, 0, 0), font=font_small)
        
        # Convertir a JPEG bytes
        buffer = io.BytesIO()
        img.save(buffer, format='JPEG', quality=85)
        return buffer.getvalue()
    
    def cleanup(self):
        """Limpiar recursos de la cámara."""
        if self.is_recording:
            self.stop_video_recording()
        
        if self.picam2 and self.picam2.started:
            self.picam2.stop()
        
        self.logger.info("🧹 Recursos de cámara liberados")