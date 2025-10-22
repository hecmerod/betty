import { Observable } from 'rxjs';
import { Photo } from '../entities/photo.entity';
import { VideoStream } from '../entities/video-stream.entity';
import { CameraType } from '../enums/camera-type.enum';

export abstract class CameraRepository {
  abstract capturePhoto(cameraType: CameraType): Observable<Photo>;
  abstract startVideoStream(cameraType: CameraType): Observable<VideoStream>;
  abstract isAvailable(cameraType: CameraType): Observable<boolean>;
}
