import { Injectable } from '@nestjs/common';
import { Observable, map } from 'rxjs';
import { CameraRepository as BaseCameraRepository } from '../../domain/repositories/camera.repository';
import { Photo } from '../../domain/entities/photo.entity';
import { VideoStream } from '../../domain/entities/video-stream.entity';
import { CameraType } from '../../domain/enums/camera-type.enum';
import { HttpCameraAdapter } from '../adapters/http-camera.adapter';
import { UsbCameraAdapter } from '../adapters/usb-camera.adapter';

@Injectable()
export class CameraRepositoryImpl extends BaseCameraRepository {
  constructor(
    private readonly httpCameraAdapter: HttpCameraAdapter,
    private readonly usbCameraAdapter: UsbCameraAdapter
  ) {
    super();
  }

  private getAdapter(cameraType: CameraType) {
    return cameraType === CameraType.INTERNAL
      ? this.usbCameraAdapter
      : this.httpCameraAdapter;
  }

  capturePhoto(cameraType: CameraType): Observable<Photo> {
    const adapter = this.getAdapter(cameraType);
    return adapter.requestPhoto().pipe(
      map((photoBuffer: Buffer) => {
        return new Photo(photoBuffer, new Date(), 'jpeg');
      })
    );
  }

  startVideoStream(cameraType: CameraType): Observable<VideoStream> {
    const adapter = this.getAdapter(cameraType);
    return adapter.requestVideoStream().pipe(
      map((stream) => {
        return new VideoStream(stream, new Date(), 'mjpeg');
      })
    );
  }

  isAvailable(cameraType: CameraType): Observable<boolean> {
    const adapter = this.getAdapter(cameraType);
    return adapter.checkAvailability();
  }
}
