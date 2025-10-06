"""
Betty Camera - Gestión de cámara con PiCamera2
"""

import io
import threading
from pathlib import Path
import time
from typing import Optional
from PIL import Image
from picamera2 import Picamera2
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from logger import get_logger

CAMERA_CONFIG = {
    "streaming_resolution": (640, 480),
    "output_dir": "output"
}

class CameraManager:
    """Gestor de cámara Raspberry Pi con PiCamera2."""
    
    def __init__(self):
        self.config = CAMERA_CONFIG
        self.logger = get_logger()
        
        self.current_frame = None
        self.capture_thread = None
        
        self.streaming_resolution = self.config.get("streaming_resolution") 

        self.output_dir = Path(self.config.get("output_dir"))
        self.output_dir.mkdir(exist_ok=True)
        
        self._init_camera()
        
        self.start_continuous_capture()
    
    def _init_camera(self):
        
        try:
            self.picam2= Picamera2()
            
            self.preview_config = self.picam2.create_video_configuration(
                main={"size": self.streaming_resolution, "format": "RGB888"}
            )            
            
        except Exception as e:
            self.logger.error(f"❌ Error inicializando cámara: {e}")
            self.picam2= None
    
    def start_continuous_capture(self):
            
        try:
            self.picam2.configure(self.preview_config)
            self.picam2.start()
            
            self.capture_thread = threading.Thread(
                target=self._capture_loop,
                daemon=True
            )
            self.capture_thread.start()
            
        except Exception as e:
            self.logger.error(f"❌ Error iniciando captura: {e}")
    
    def _capture_loop(self):
        while self.picam2:
            try:
                frame_array = self.picam2.capture_array()
                
                image = Image.fromarray(frame_array)
                buffer = io.BytesIO()
                image.save(buffer, format='JPEG', quality=80)
                
                self.current_frame = buffer.getvalue()
                
                time.sleep(0.033)
                
            except Exception as e:
                self.logger.error(f"❌ Error en captura: {e}")
                break
    
    def get_current_frame(self) -> Optional[bytes]:
        return self.current_frame
    
    
    def stop_continuous_capture(self):    
        if self.capture_thread and self.capture_thread.is_alive():
            self.capture_thread.join(timeout=2)
            
        if self.picam2:
            try:
                self.picam2.stop()
            except:
                pass                
    
    def cleanup(self):
        self.stop_continuous_capture()