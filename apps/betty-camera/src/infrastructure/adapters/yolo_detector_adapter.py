import time
import numpy as np
from ultralytics import YOLO
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
from logger import get_logger
from domain.models.detection import Detection, DetectionResult, BoundingBox


class YoloDetectorAdapter:
    def __init__(self, model_path: str = "yolov8n_ncnn_model", confidence_threshold: float = 0.5):
        self.logger = get_logger()
        self.confidence_threshold = confidence_threshold
        
        try:
            self.model = YOLO(model_path)
            self.logger.info(f"✅ Modelo YOLO cargado: {model_path}")
        except Exception as e:
            self.logger.error(f"❌ Error cargando modelo YOLO: {e}")
            self.model = None
    
    def detect(self, frame: np.ndarray) -> DetectionResult:
        if self.model is None:
            return DetectionResult(
                detections=[],
                frame_width=frame.shape[1],
                frame_height=frame.shape[0],
                processing_time_ms=0
            )
        
        start_time = time.time()
        
        try:
            results = self.model(frame, verbose=False, classes=[0])
            
            detections = []
            for result in results:
                boxes = result.boxes
                if boxes is not None:
                    for box in boxes:
                        conf = float(box.conf[0].cpu().numpy())
                        
                        if conf < self.confidence_threshold:
                            continue
                        
                        xyxy = box.xyxy[0].cpu().numpy()
                        
                        detection = Detection(
                            class_name='person',
                            confidence=round(conf, 3),
                            bounding_box=BoundingBox(
                                x=int(xyxy[0]),
                                y=int(xyxy[1]),
                                width=int(xyxy[2] - xyxy[0]),
                                height=int(xyxy[3] - xyxy[1])
                            )
                        )
                        detections.append(detection)
            
            processing_time = (time.time() - start_time) * 1000
            
            return DetectionResult(
                detections=detections,
                frame_width=frame.shape[1],
                frame_height=frame.shape[0],
                processing_time_ms=round(processing_time, 2)
            )
            
        except Exception as e:
            self.logger.error(f"❌ Error en detección: {e}")
            return DetectionResult(
                detections=[],
                frame_width=frame.shape[1],
                frame_height=frame.shape[0],
                processing_time_ms=0
            )
