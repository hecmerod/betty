import { Injectable } from '@nestjs/common';
import { Observable, map } from 'rxjs';
import { VideoStream } from '../../../domain/entities/video-stream.entity';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { HttpCameraAdapter } from '../../../infrastructure/adapters/http-camera.adapter';
import { UsbCameraAdapter } from '../../../infrastructure/adapters/usb-camera.adapter';

@Injectable()
export class GetVideoStreamUseCase {
  constructor(
    private readonly httpCameraAdapter: HttpCameraAdapter,
    private readonly usbCameraAdapter: UsbCameraAdapter
  ) {}

  execute(
    cameraType: CameraType,
    cameraIndex?: number
  ): Observable<VideoStream> {
    if (
      cameraType === CameraType.INTERNAL ||
      cameraType === CameraType.EXTERNAL
    ) {
      return this.usbCameraAdapter
        .requestVideoStream(cameraType, cameraIndex)
        .pipe(
          map((stream) => {
            return new VideoStream(stream, new Date(), 'mjpeg');
          })
        );
    }

    return this.httpCameraAdapter.requestVideoStream().pipe(
      map((stream) => {
        return new VideoStream(stream, new Date(), 'mjpeg');
      })
    );
  }
}
