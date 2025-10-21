import time
import threading
from typing import Optional
import numpy as np
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
from logger import get_logger
from application.use_cases.detect_objects_use_case import DetectObjectsUseCase
from application.use_cases.trigger_alarm_use_case import TriggerAlarmUseCase
from infrastructure.adapters.camera_adapter import CameraAdapter


class DetectionService:
    def __init__(
        self,
        camera_adapter: CameraAdapter,
        detect_objects_use_case: DetectObjectsUseCase,
        trigger_alarm_use_case: TriggerAlarmUseCase
    ):
        self.logger = get_logger()
        self.camera = camera_adapter
        self.detect_objects = detect_objects_use_case
        self.trigger_alarm = trigger_alarm_use_case
        
        self.detection_mode_active = False
        self.last_detection_time = 0
        self.detection_interval = 2.0
        self.frames_without_detection = 0
        self.max_frames_without_detection = 60
        
        self.last_alarm_time = 0
        self.alarm_interval = 10.0
        
        self.running = False
        self.detection_thread: Optional[threading.Thread] = None
    
    def start(self):
        if self.running:
            return
        
        self.running = True
        self.detection_thread = threading.Thread(
            target=self._detection_loop,
            daemon=True
        )
        self.detection_thread.start()
        self.logger.info("✅ Servicio de detección iniciado")
    
    def stop(self):
        self.running = False
        if self.detection_thread and self.detection_thread.is_alive():
            self.detection_thread.join(timeout=2)
        self.logger.info("✅ Servicio de detección detenido")
    
    def _detection_loop(self):
        while self.running:
            try:
                current_time = time.time()
                
                should_detect = False
                if self.detection_mode_active:
                    should_detect = True
                elif current_time - self.last_detection_time >= self.detection_interval:
                    should_detect = True
                
                if should_detect:
                    frame = self.camera.capture_array()
                    if frame is not None:
                        result = self.detect_objects.execute(frame)
                        self.last_detection_time = current_time
                        
                        if len(result.detections) > 0:
                            persons = [d.class_name for d in result.detections]
                            self.logger.info(f"🔍 Objetos detectados: {persons}")
                            
                            self._handle_detection(current_time, result)
                            
                            if not self.detection_mode_active:
                                self.detection_mode_active = True
                                self.logger.info("🚀 Modo detección CONTINUO")
                            
                            self.frames_without_detection = 0
                        else:
                            if self.detection_mode_active:
                                self.frames_without_detection += 1
                                
                                if self.frames_without_detection >= self.max_frames_without_detection:
                                    self.detection_mode_active = False
                                    self.frames_without_detection = 0
                                    self.logger.info("🐌 Modo detección NORMAL (cada 2s)")
                
                time.sleep(0.1)
                
            except Exception as e:
                self.logger.error(f"❌ Error en loop de detección: {e}")
                time.sleep(1)
    
    def _handle_detection(self, current_time: float, detection_result):
        if current_time - self.last_alarm_time >= self.alarm_interval:
            try:
                self.logger.warning("⚡ ALARMA - Persona detectada")
                self.trigger_alarm.execute(
                    event_type='person_detected',
                    metadata={
                        'detections_count': len(detection_result.detections),
                        'processing_time_ms': detection_result.processing_time_ms
                    }
                )
                self.last_alarm_time = current_time
            except Exception as e:
                self.logger.error(f"❌ Error disparando alarma: {e}")
