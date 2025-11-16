import { Injectable, Logger } from '@nestjs/common';
import { Observable, of, map } from 'rxjs';
import { VideoStream } from '../../../domain/entities/video-stream.entity';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { UsbCameraAdapter } from '../../../infrastructure/adapters/usb-camera.adapter';
import { CameraDetectionProcess } from '../../processes/camera-detection.process';

@Injectable()
export class GetVideoStreamUseCase {
  private readonly logger = new Logger(GetVideoStreamUseCase.name);

  constructor(
    private readonly usbCameraAdapter: UsbCameraAdapter,
    private readonly cameraDetectionProcess: CameraDetectionProcess
  ) {}

  execute(
    cameraType: CameraType,
    cameraIndex?: number
  ): Observable<VideoStream> {
    if (cameraType === CameraType.INTERNAL) {
      const stream = this.cameraDetectionProcess.getStream();
      return of(new VideoStream(stream, new Date(), 'mjpeg'));
    }

    if (cameraType === CameraType.EXTERNAL) {
      return this.usbCameraAdapter
        .requestVideoStream(cameraType, cameraIndex)
        .pipe(map((stream) => new VideoStream(stream, new Date(), 'mjpeg')));
    }
  }
}
