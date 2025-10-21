import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from infrastructure.adapters.camera_adapter import CameraAdapter
from infrastructure.adapters.yolo_detector_adapter import YoloDetectorAdapter
from infrastructure.adapters.betty_server_adapter import BettyServerAdapter
from infrastructure.adapters.alarm_adapter import AlarmAdapter
from application.use_cases.capture_frame_use_case import CaptureFrameUseCase
from application.use_cases.detect_objects_use_case import DetectObjectsUseCase
from application.use_cases.trigger_alarm_use_case import TriggerAlarmUseCase
from application.services.detection_service import DetectionService
from config.settings import settings


class DependencyContainer:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self.camera_adapter = CameraAdapter(
            width=settings.CAMERA_WIDTH,
            height=settings.CAMERA_HEIGHT,
            fps=settings.CAMERA_FPS
        )
        
        self.detector_adapter = YoloDetectorAdapter(
            model_path=settings.YOLO_MODEL_PATH,
            confidence_threshold=settings.YOLO_CONFIDENCE
        )
        
        self.betty_server_adapter = BettyServerAdapter(
            base_url=settings.BETTY_SERVER_URL,
            token=settings.BETTY_SERVER_TOKEN
        )
        
        self.alarm_adapter = AlarmAdapter(self.betty_server_adapter)
        
        self.capture_frame_use_case = CaptureFrameUseCase(self.camera_adapter)
        self.detect_objects_use_case = DetectObjectsUseCase(self.detector_adapter)
        self.trigger_alarm_use_case = TriggerAlarmUseCase(self.alarm_adapter)
        
        self.detection_service = DetectionService(
            self.camera_adapter,
            self.detect_objects_use_case,
            self.trigger_alarm_use_case
        )
        
        self._initialized = True


def get_container() -> DependencyContainer:
    return DependencyContainer()
