import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { CameraController } from './presentation/controllers/camera.controller';
import { CapturePhotoUseCase } from './application/use-cases/capture-photo/capture-photo.use-case';
import { GetVideoStreamUseCase } from './application/use-cases/get-video-stream/get-video-stream.use-case';
import { GetGridVideoStreamUseCase } from './application/use-cases/get-grid-video-stream/get-grid-video-stream.use-case';
import { CheckCameraAvailabilityUseCase } from './application/use-cases/check-camera-availability/check-camera-availability.use-case';
import { HttpCameraAdapter } from './infrastructure/adapters/http-camera.adapter';
import { UsbCameraAdapter } from './infrastructure/adapters/usb-camera.adapter';
import { MultiCameraGridService } from './infrastructure/services/multi-camera-grid.service';
import { UsbCameraDetectorService } from './infrastructure/services/usb-camera-detector.service';
import { ObjectDetectionService } from './infrastructure/services/object-detection.service';
import { VideoDetectionService } from './infrastructure/services/video-detection.service';

@Module({
  imports: [
    HttpModule.register({
      timeout: 30000,
      maxRedirects: 5,
    }),
  ],
  controllers: [CameraController],
  providers: [
    CapturePhotoUseCase,
    GetVideoStreamUseCase,
    GetGridVideoStreamUseCase,
    CheckCameraAvailabilityUseCase,
    MultiCameraGridService,
    UsbCameraDetectorService,
    ObjectDetectionService,
    VideoDetectionService,
    HttpCameraAdapter,
    UsbCameraAdapter,
  ],
  exports: [
    CapturePhotoUseCase,
    GetVideoStreamUseCase,
    GetGridVideoStreamUseCase,
    CheckCameraAvailabilityUseCase,
    ObjectDetectionService,
  ],
})
export class CameraModule {}
