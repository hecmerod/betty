import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { CameraController } from './presentation/controllers/camera.controller';
import { CapturePhotoUseCase } from './application/use-cases/capture-photo/capture-photo.use-case';
import { GetVideoStreamUseCase } from './application/use-cases/get-video-stream/get-video-stream.use-case';
import { CheckCameraAvailabilityUseCase } from './application/use-cases/check-camera-availability/check-camera-availability.use-case';
import { HttpCameraAdapter } from './infrastructure/adapters/http-camera.adapter';
import { UsbCameraAdapter } from './infrastructure/adapters/usb-camera.adapter';
import { CameraRepositoryImpl } from './infrastructure/repositories/camera.repository';
import { CAMERA_REPOSITORY } from './infrastructure/ioc/symbols';

@Module({
  imports: [
    HttpModule.register({
      timeout: 30000,
      maxRedirects: 5,
    }),
  ],
  controllers: [CameraController],
  providers: [
    // Unified Use Cases
    CapturePhotoUseCase,
    GetVideoStreamUseCase,
    CheckCameraAvailabilityUseCase,
    // Adapters
    HttpCameraAdapter,
    UsbCameraAdapter,
    // Unified Repository
    {
      provide: CAMERA_REPOSITORY,
      useClass: CameraRepositoryImpl,
    },
  ],
  exports: [
    CapturePhotoUseCase,
    GetVideoStreamUseCase,
    CheckCameraAvailabilityUseCase,
  ],
})
export class CameraModule {}
