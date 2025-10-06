"""
Betty Camera - Detección de objetos con YOLO
"""

import cv2
import numpy as np
from ultralytics import YOLO
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from logger import get_logger

class ObjectDetector:    
    def __init__(self):
        self.logger = get_logger()  

        self.model = YOLO("yolov8n_ncnn_model")   
    
    def detect_persons(self, frame_array: np.ndarray) -> dict:        
        try:
            results = self.model(frame_array, verbose=False, classes=[0])

            detections = []
            for result in results:
                boxes = result.boxes
                if boxes is not None:
                    for box in boxes:
                        conf = float(box.conf[0].cpu().numpy())   

                        if conf < 0.5: break

                        xyxy = box.xyxy[0].cpu().numpy()                      
                        
                        person = {
                            "class": 'person',
                            "confidence": round(conf, 3),
                            "bbox": {
                                "x1": int(xyxy[0]),
                                "y1": int(xyxy[1]), 
                                "x2": int(xyxy[2]),
                                "y2": int(xyxy[3])
                            }
                        }
                        
                        detections.append(person)
            
            return {
                "detections": detections,
                "count": len(detections),
                "timestamp": self._get_timestamp()
            }
            
        except Exception as e:
            self.logger.error(f"❌ Error en detección de objetos: {e}")
            return {"detections": [], "count": 0, "error": str(e)}
    
    def draw_persons(self, frame_array: np.ndarray, persons: dict) -> np.ndarray:
        if not persons.get("detections"):
            return frame_array
        
        try:
            annotated_frame = frame_array.copy()
            
            
            for person in persons["detections"]:
                bbox = person["bbox"]
                class_name = person["class"]
                confidence = person["confidence"]
                
                cv2.rectangle(
                    annotated_frame,
                    (bbox["x1"], bbox["y1"]),
                    (bbox["x2"], bbox["y2"]),
                    (0, 255, 0),  # Verde
                    2
                )
                
                label = f"{class_name}: {confidence:.2f}"
                label_size = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)[0]
                text_width, text_height = label_size
                
                # Posición del rectángulo de fondo DENTRO del bounding box, esquina superior izq
                rect_x1 = bbox["x1"] + 5  # 5px de margen desde el borde
                rect_y1 = bbox["y1"] + 5  # 5px de margen desde el borde
                rect_x2 = bbox["x1"] + text_width + 15  # ancho del texto + padding
                rect_y2 = bbox["y1"] + text_height + 15  # alto del texto + padding
                
                # Dibujar rectángulo de fondo DENTRO del bounding box
                cv2.rectangle(
                    annotated_frame,
                    (rect_x1, rect_y1),
                    (rect_x2, rect_y2),
                    (0, 255, 0),  # Verde
                    -1
                )
                
                # Dibujar texto dentro del rectángulo de fondo
                text_x = bbox["x1"] + 10  # 10px de margen desde el borde
                text_y = bbox["y1"] + text_height + 10  # posición baseline del texto
                
                cv2.putText(
                    annotated_frame,
                    label,
                    (text_x, text_y),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.5,
                    (0, 0, 0),  # Negro
                    2
                )
            
            return annotated_frame
            
        except Exception as e:
            self.logger.error(f"❌ Error dibujando detecciones: {e}")
            return frame_array
    
    def _get_timestamp(self):
        import datetime
        return datetime.datetime.now().isoformat()