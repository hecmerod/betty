import { Observable } from 'rxjs';
import { Photo } from '../entities/photo.entity';
import { VideoStream } from '../entities/video-stream.entity';

export abstract class CameraRepository {
  abstract capturePhoto(): Observable<Photo>;
  abstract startVideoStream(): Observable<VideoStream>;
  abstract isAvailable(): Observable<boolean>;
}
