class CaptureFrameUseCase:
    def __init__(self, camera_adapter):
        self.camera = camera_adapter
    
    def execute(self):
        return self.camera.capture_frame()
