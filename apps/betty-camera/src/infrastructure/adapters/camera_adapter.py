import io
import threading
import time
from typing import Optional
from PIL import Image
from picamera2 import Picamera2
import numpy as np
import cv2
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
from logger import get_logger


class CameraAdapter:
    def __init__(self, width: int = 640, height: int = 480, fps: int = 30):
        self.logger = get_logger()
        self.width = width
        self.height = height
        self.fps = fps
        
        self.current_frame = None
        self.current_frame_array = None
        self.capture_thread = None
        self.running = False
        
        self.picam2 = None
        self._init_camera()
    
    def _init_camera(self):
            self.picam2 = Picamera2()
            
            self.preview_config = self.picam2.create_video_configuration(
                main={"size": (self.width, self.height), "format": "RGB888"}
            )            
    
    def start(self):  
        self.picam2.configure(self.preview_config)
        self.picam2.start()
        
        self.running = True
        self.capture_thread = threading.Thread(
            target=self._capture_loop,
            daemon=True
        )
        self.capture_thread.start()        
    
    def _capture_loop(self):
        while self.running and self.picam2:
            try:
                self.current_frame_array = self.picam2.capture_array() 
                
                time.sleep(1.0 / self.fps)
            except Exception as e:
                self.logger.error(f"❌ Error en captura: {e}")
                break
    
    def capture_frame(self) -> Optional[bytes]:
        fixed_frame = cv2.cvtColor(self.current_frame_array, cv2.COLOR_RGB2BGR)
        image = Image.fromarray(fixed_frame)
        buffer = io.BytesIO()
        image.save(buffer, format='JPEG', quality=80)
        
        self.current_frame = buffer.getvalue()

        return self.current_frame
    
    def stop(self):
        self.running = False
        
        if self.capture_thread and self.capture_thread.is_alive():
            self.capture_thread.join(timeout=2)
        
        if self.picam2:
            try:
                self.picam2.stop()
                self.logger.info("✅ Cámara detenida")
            except Exception as e:
                self.logger.error(f"❌ Error deteniendo cámara: {e}")
