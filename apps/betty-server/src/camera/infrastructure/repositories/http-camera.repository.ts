import { Injectable } from '@nestjs/common';
import { Observable, map } from 'rxjs';
import { CameraRepository } from '../../domain/repositories/camera.repository';
import { Photo } from '../../domain/entities/photo.entity';
import { VideoStream } from '../../domain/entities/video-stream.entity';
import { HttpCameraAdapter } from '../adapters/http-camera.adapter';

@Injectable()
export class HttpCameraRepository extends CameraRepository {
  constructor(private readonly httpCameraAdapter: HttpCameraAdapter) {
    super();
  }

  capturePhoto(): Observable<Photo> {
    return this.httpCameraAdapter.requestPhoto().pipe(
      map((photoBuffer: Buffer) => {
        return new Photo(photoBuffer, new Date(), 'jpeg');
      })
    );
  }

  startVideoStream(): Observable<VideoStream> {
    return this.httpCameraAdapter.requestVideoStream().pipe(
      map((stream) => {
        return new VideoStream(stream, new Date(), 'mjpeg');
      })
    );
  }

  isAvailable(): Observable<boolean> {
    return this.httpCameraAdapter.checkAvailability();
  }
}
