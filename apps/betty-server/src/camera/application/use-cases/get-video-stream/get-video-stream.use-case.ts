import { Injectable, Logger } from '@nestjs/common';
import { Observable, of, map } from 'rxjs';
import { VideoStream } from '../../../domain/entities/video-stream.entity';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { HttpCameraAdapter } from '../../../infrastructure/adapters/http-camera.adapter';
import { UsbCameraAdapter } from '../../../infrastructure/adapters/usb-camera.adapter';
import { CameraDetectionProcess } from '../../../infrastructure/processes/camera-detection.process';

@Injectable()
export class GetVideoStreamUseCase {
  private readonly logger = new Logger(GetVideoStreamUseCase.name);

  constructor(
    private readonly usbCameraAdapter: UsbCameraAdapter,
    private readonly httpCameraAdapter: HttpCameraAdapter,
    private readonly cameraDetectionProcess: CameraDetectionProcess
  ) {}

  execute(
    cameraType: CameraType,
    cameraIndex?: number
  ): Observable<VideoStream> {
    // Cámara INTERNAL: usar servicio centralizado
    if (cameraType === CameraType.INTERNAL) {
      this.logger.log('📹 Obteniendo stream de cámara interna (compartido)');
      const stream = this.cameraDetectionProcess.getStream();
      return of(new VideoStream(stream, new Date(), 'mjpeg'));
    }

    // Cámara EXTERNAL: crear stream independiente
    if (cameraType === CameraType.EXTERNAL) {
      return this.usbCameraAdapter
        .requestVideoStream(cameraType, cameraIndex)
        .pipe(map((stream) => new VideoStream(stream, new Date(), 'mjpeg')));
    }

    // Otras cámaras (HTTP)
    return this.httpCameraAdapter
      .requestVideoStream()
      .pipe(map((stream) => new VideoStream(stream, new Date(), 'mjpeg')));
  }
}
