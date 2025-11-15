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

  execute(cameraType: CameraType): Observable<VideoStream> {
    const adapter =
      cameraType === CameraType.EXTERNAL
        ? this.usbCameraAdapter
        : this.httpCameraAdapter;

    return adapter.requestVideoStream().pipe(
      map((stream) => {
        return new VideoStream(stream, new Date(), 'mjpeg');
      })
    );
  }
}
