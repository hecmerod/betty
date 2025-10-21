import os
from typing import Optional


class Settings:
    HOST: str = os.getenv('HOST', '0.0.0.0')
    PORT: int = int(os.getenv('PORT', '8001'))
    LOG_LEVEL: str = os.getenv('LOG_LEVEL', 'INFO')
    
    BETTY_SERVER_URL: str = os.getenv('BETTY_SERVER_URL', 'http://localhost:3000/api')
    BETTY_SERVER_TOKEN: Optional[str] = os.getenv('BETTY_SERVER_TOKEN')
    
    CAMERA_WIDTH: int = int(os.getenv('CAMERA_WIDTH', '640'))
    CAMERA_HEIGHT: int = int(os.getenv('CAMERA_HEIGHT', '480'))
    CAMERA_FPS: int = int(os.getenv('CAMERA_FPS', '30'))
    
    YOLO_MODEL_PATH: str = os.getenv('YOLO_MODEL_PATH', 'yolov8n.pt')
    YOLO_CONFIDENCE: float = float(os.getenv('YOLO_CONFIDENCE', '0.5'))
    
    ENABLE_OBJECT_DETECTION: bool = os.getenv('ENABLE_OBJECT_DETECTION', 'true').lower() == 'true'


settings = Settings()
