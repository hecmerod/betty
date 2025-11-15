import { Injectable } from '@nestjs/common';
import { Observable, map } from 'rxjs';
import { VideoStream } from '../../../domain/entities/video-stream.entity';
import { UsbCameraAdapter } from '../../../infrastructure/adapters/usb-camera.adapter';

@Injectable()
export class GetGridVideoStreamUseCase {
  constructor(private readonly usbCameraAdapter: UsbCameraAdapter) {}

  execute(): Observable<VideoStream> {
    return this.usbCameraAdapter.requestGridVideoStream().pipe(
      map((stream) => {
        return new VideoStream(stream, new Date(), 'mjpeg');
      })
    );
  }
}
