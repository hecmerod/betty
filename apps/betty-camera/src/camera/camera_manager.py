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
import numpy as np
import sys
import os
import cv2

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from logger import get_logger
from object_detector import ObjectDetector

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
        self.current_detections = None
        self.capture_thread = None
        
        self.detection_mode_active = False 
        self.last_detection_time = 0
        self.detection_interval = 2.0 
        self.frames_without_detection = 0
        self.max_frames_without_detection = 60
        
        self.object_detector = ObjectDetector()
        
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
    
    def _process_detection(self, frame_array: np.ndarray, current_time: float) -> bool:
        should_detect = False
        
        if self.detection_mode_active:
            should_detect = True
        else:
            if current_time - self.last_detection_time >= self.detection_interval:
                should_detect = True
        
        if should_detect:
            detections = self.object_detector.detect_persons(frame_array)
            self.current_detections = detections
            self.last_detection_time = current_time
            
            if detections.get("count", 0) > 0:
                persons = [d["class"] for d in detections["detections"]]
                self.logger.info(f"🔍 Objetos detectados: {persons}")
                
                if not self.detection_mode_active:
                    self.detection_mode_active = True
                    self.logger.info("⚡ Modo detección ACTIVO (cada frame)")
                
                self.frames_without_detection = 0
                
            else:
                if self.detection_mode_active:
                    self.frames_without_detection += 1
                    
                    if self.frames_without_detection >= self.max_frames_without_detection:
                        self.detection_mode_active = False
                        self.frames_without_detection = 0
                        self.logger.info("🐌 Modo detección NORMAL (cada 2s)")
        
        return should_detect
    
    def _capture_loop(self):
        """Loop principal de captura de frames con detección adaptativa."""
        while self.picam2:
            try:
                frame_array = self.picam2.capture_array()
                current_time = time.time()
                
                # Procesar detección adaptativa
                self._process_detection(frame_array, current_time)
                
                fixed_frame = cv2.cvtColor(frame_array, cv2.COLOR_RGB2BGR)
                
                # Convertir frame a JPEG
                image = Image.fromarray(fixed_frame)
                buffer = io.BytesIO()
                image.save(buffer, format='JPEG', quality=80)

                self.current_frame = buffer.getvalue()

                # 30 FPS
                time.sleep(0.033)

            except Exception as e:
                self.logger.error(f"❌ Error en captura: {e}")
                break
    
    def get_current_frame(self) -> Optional[bytes]:
        return self.current_frame
    
    def get_annotated_frame(self) -> Optional[bytes]:        
        try:
            image = Image.open(io.BytesIO(self.current_frame))
            frame_array = np.array(image)
            
            annotated_array = self.object_detector.draw_persons(frame_array, self.current_detections)
            
            annotated_image = Image.fromarray(annotated_array)
            buffer = io.BytesIO()
            annotated_image.save(buffer, format='JPEG', quality=80)
            
            return buffer.getvalue()
            
        except Exception as e:
            self.logger.error(f"❌ Error generando frame anotado: {e}")
            return self.current_frame
    
    def get_current_detections(self) -> dict:
        """Obtener las detecciones actuales."""
        return self.current_detections or {"detections": [], "count": 0}
    
    def get_detection_status(self) -> dict:
        """Obtener estado del sistema de detección adaptativo."""
        current_time = time.time()
        time_since_last_detection = current_time - self.last_detection_time
        
        return {
            "detection_mode_active": self.detection_mode_active,
            "mode_description": "Cada frame" if self.detection_mode_active else "Cada 2 segundos",
            "time_since_last_detection": round(time_since_last_detection, 2),
            "frames_without_detection": self.frames_without_detection,
            "max_frames_threshold": self.max_frames_without_detection,
            "detection_interval": self.detection_interval,
            "current_detections_count": self.get_current_detections().get("count", 0)
        }
    
    def force_detection_mode(self, active: bool):
        """Forzar cambio de modo de detección (útil para debug)."""
        old_mode = "activo" if self.detection_mode_active else "normal"
        new_mode = "activo" if active else "normal"
        
        self.detection_mode_active = active
        self.frames_without_detection = 0
        
        self.logger.info(f"🔧 Modo detección cambiado manualmente: {old_mode} → {new_mode}")
    
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