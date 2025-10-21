class CaptureFrameUseCase:
    def __init__(self, camera_adapter, detector_adapter):
        self.camera = camera_adapter
        self.detector = detector_adapter
    
    def execute(self, annotated: bool = False):
        if annotated:
            return self.detector.capture_frame()
        
        return self.camera.capture_frame()
