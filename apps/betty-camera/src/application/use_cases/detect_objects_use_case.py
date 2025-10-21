from typing import List
from domain.models.detection import Detection, DetectionResult, BoundingBox


class DetectObjectsUseCase:
    def __init__(self, detector_adapter):
        self.detector = detector_adapter
    
    def execute(self, frame) -> DetectionResult:
        return self.detector.detect(frame)
