from dataclasses import dataclass
from typing import List, Optional
from datetime import datetime


@dataclass
class BoundingBox:
    x: int
    y: int
    width: int
    height: int


@dataclass
class Detection:
    class_name: str
    confidence: float
    bounding_box: BoundingBox
    timestamp: datetime = None
    
    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.now()
    
    def to_dict(self):
        return {
            'class_name': self.class_name,
            'confidence': self.confidence,
            'bounding_box': {
                'x': self.bounding_box.x,
                'y': self.bounding_box.y,
                'width': self.bounding_box.width,
                'height': self.bounding_box.height
            },
            'timestamp': self.timestamp.isoformat()
        }


@dataclass
class DetectionResult:
    detections: List[Detection]
    frame_width: int
    frame_height: int
    processing_time_ms: float
    
    def to_dict(self):
        return {
            'detections': [d.to_dict() for d in self.detections],
            'frame_width': self.frame_width,
            'frame_height': self.frame_height,
            'processing_time_ms': self.processing_time_ms,
            'total_detections': len(self.detections)
        }
