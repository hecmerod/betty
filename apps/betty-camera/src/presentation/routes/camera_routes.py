from fastapi import APIRouter, Response, Query
from fastapi.responses import StreamingResponse
import json
import time
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
from infrastructure.config.dependencies import get_container
from logger import get_logger

camera_router = APIRouter(tags=["camera"])
logger = get_logger()


@camera_router.get("/photo")
async def get_camera_photo():
    container = get_container()
    frame = container.capture_frame_use_case.execute()
    
    if not frame:
        return Response(content=b'', media_type="image/jpeg", status_code=503)
    
    return Response(content=frame, media_type="image/jpeg")


@camera_router.get("/video")
async def get_camera_stream(annotated: bool = Query(False)):
    container = get_container()
    
    def generate_stream():
        start_time = time.time()
        timeout = 30
        timeout_json = json.dumps({"connectionReseted": True})
        
        while time.time() - start_time < timeout:
            frame = container.capture_frame_use_case.execute()
            
            if frame:
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
            
            time.sleep(0.033)
        
        yield (b'--frame\r\n'
               b'Content-Type: application/json\r\n\r\n' + timeout_json.encode() + b'\r\n')
    
    return StreamingResponse(
        generate_stream(),
        media_type="multipart/x-mixed-replace; boundary=frame"
    )
