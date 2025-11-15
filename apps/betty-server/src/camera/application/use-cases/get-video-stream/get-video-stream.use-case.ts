import { Injectable, Logger } from '@nestjs/common';
import { Observable, map } from 'rxjs';
import { VideoStream } from '../../../domain/entities/video-stream.entity';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { HttpCameraAdapter } from '../../../infrastructure/adapters/http-camera.adapter';
import { UsbCameraAdapter } from '../../../infrastructure/adapters/usb-camera.adapter';
import { VideoDetectionService } from '../../../infrastructure/services/video-detection.service';
import { ObjectDetectionService } from '../../../infrastructure/services/object-detection.service';

@Injectable()
export class GetVideoStreamUseCase {
  private readonly logger = new Logger(GetVideoStreamUseCase.name);
  private readonly enableDetection: boolean;

  constructor(
    private readonly httpCameraAdapter: HttpCameraAdapter,
    private readonly usbCameraAdapter: UsbCameraAdapter,
    private readonly videoDetectionService: VideoDetectionService,
    private readonly objectDetectionService: ObjectDetectionService
  ) {
    this.enableDetection =
      process.env.ENABLE_OBJECT_DETECTION?.toLowerCase() === 'true';
  }

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
            if (
              cameraType === CameraType.INTERNAL &&
              this.enableDetection &&
              this.objectDetectionService.isModelLoaded()
            ) {
              // Procesar stream con detección
              const detectionStream =
                this.videoDetectionService.processVideoStream(
                  stream,
                  (result) => {
                    this.logger.warn(
                      `⚠️ Person detected! Count: ${result.totalDetections}, Processing time: ${result.processingTimeMs}ms`
                    );
                  }
                );

              return new VideoStream(detectionStream, new Date(), 'mjpeg');
            }

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
