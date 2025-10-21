import time
from typing import Optional
import numpy as np
import cv2
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
        self.current_frame_annotated_array = None
        
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
            # Crear copia del frame para dibujar
            annotated_frame = frame.copy()
            
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
                        x1, y1, x2, y2 = int(xyxy[0]), int(xyxy[1]), int(xyxy[2]), int(xyxy[3])
                        
                        # Dibujar rectángulo en el frame anotado
                        cv2.rectangle(annotated_frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                        
                        # Dibujar etiqueta con confianza
                        label = f'person {conf:.2f}'
                        label_size, _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)
                        cv2.rectangle(annotated_frame, (x1, y1 - label_size[1] - 10), (x1 + label_size[0], y1), (0, 255, 0), -1)
                        cv2.putText(annotated_frame, label, (x1, y1 - 5), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0), 2)
                        
                        detection = Detection(
                            class_name='person',
                            confidence=round(conf, 3),
                            bounding_box=BoundingBox(
                                x=x1,
                                y=y1,
                                width=x2 - x1,
                                height=y2 - y1
                            )
                        )
                        detections.append(detection)
            
            # Guardar el frame anotado
            self.current_frame_annotated_array = annotated_frame
            
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
    
    def capture_frame(self) -> Optional[bytes]:
        if self.current_frame_annotated_array is None:
            return None
        
        try:
            fixed_frame = cv2.cvtColor(self.current_frame_annotated_array, cv2.COLOR_RGB2BGR)
            _, buffer = cv2.imencode('.jpg', fixed_frame, [cv2.IMWRITE_JPEG_QUALITY, 80])
            return buffer.tobytes()
        except Exception as e:
            self.logger.error(f"❌ Error convirtiendo frame a JPEG: {e}")
            return None
