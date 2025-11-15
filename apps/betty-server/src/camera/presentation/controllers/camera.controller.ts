import {
  Controller,
  Get,
  Res,
  Query,
  InternalServerErrorException,
  BadRequestException,
} from '@nestjs/common';
import { Response } from 'express';
import { CapturePhotoUseCase } from '../../application/use-cases/capture-photo/capture-photo.use-case';
import { GetVideoStreamUseCase } from '../../application/use-cases/get-video-stream/get-video-stream.use-case';
import { GetGridVideoStreamUseCase } from '../../application/use-cases/get-grid-video-stream/get-grid-video-stream.use-case';
import { CheckCameraAvailabilityUseCase } from '../../application/use-cases/check-camera-availability/check-camera-availability.use-case';
import { ObjectDetectionService } from '../../infrastructure/services/object-detection.service';
import { CameraType } from '../../domain/enums/camera-type.enum';

@Controller('/camera')
export class CameraController {
  constructor(
    private readonly capturePhotoUseCase: CapturePhotoUseCase,
    private readonly getVideoStreamUseCase: GetVideoStreamUseCase,
    private readonly getGridVideoStreamUseCase: GetGridVideoStreamUseCase,
    private readonly checkCameraAvailabilityUseCase: CheckCameraAvailabilityUseCase,
    private readonly objectDetectionService: ObjectDetectionService
  ) {}

  private getCameraType(type?: string): CameraType {
    if (type === 'external') return CameraType.EXTERNAL;

    if (type === 'internal') return CameraType.INTERNAL;

    throw new BadRequestException(
      'Invalid camera type. Use "internal" or "external"'
    );
  }

  @Get('photo')
  async capturePhoto(
    @Query('type') type: string,
    @Query('index') index?: string,
    @Res() res?: Response
  ): Promise<void> {
    try {
      const cameraType = this.getCameraType(type);
      const cameraIndex = index !== undefined ? parseInt(index, 10) : undefined;

      if (cameraIndex !== undefined && isNaN(cameraIndex)) {
        throw new BadRequestException('Invalid camera index');
      }

      this.capturePhotoUseCase.execute(cameraType, cameraIndex).subscribe({
        next: (photo) => {
          res.set({
            'Content-Type': photo.getMimeType(),
            'Content-Length': photo.getSize().toString(),
            'Cache-Control': 'no-cache',
          });
          res.end(photo.data);
        },
        error: () => {
          if (!res.headersSent) {
            res.status(500).json({
              error: 'Failed to capture photo',
              message: `${cameraType} camera service unavailable`,
            });
          }
        },
      });
    } catch (error) {
      if (error instanceof BadRequestException) {
        res.status(400).json({
          error: 'Bad Request',
          message: error.message,
        });
      } else {
        throw new InternalServerErrorException('Failed to capture photo');
      }
    }
  }

  @Get('video')
  async getVideoStream(
    @Query('type') type: string,
    @Query('index') index?: string,
    @Query('grid') grid?: string,
    @Res() res?: Response
  ): Promise<void> {
    try {
      const cameraType = this.getCameraType(type);
      const cameraIndex = index !== undefined ? parseInt(index, 10) : undefined;
      const useGrid = grid === 'true';

      if (cameraIndex !== undefined && isNaN(cameraIndex))
        throw new BadRequestException('Invalid camera index');

      if (useGrid && cameraType !== CameraType.EXTERNAL)
        throw new BadRequestException(
          'Grid view is only available for external cameras'
        );

      res.set({
        'Content-Type': 'multipart/x-mixed-replace; boundary=frame',
        'Cache-Control': 'no-cache',
        Connection: 'keep-alive',
        Pragma: 'no-cache',
      });

      const observable = useGrid
        ? this.getGridVideoStreamUseCase.execute()
        : this.getVideoStreamUseCase.execute(cameraType, cameraIndex);

      const subscription = observable.subscribe({
        next: (videoStream) => {
          videoStream.stream.pipe(res);

          res.on('close', () => {
            subscription.unsubscribe();
            videoStream.stream.destroy();
          });
        },
        error: () => {
          if (!res.headersSent) {
            res.status(500).json({
              error: 'Failed to start video stream',
              message: `${cameraType} camera service unavailable`,
            });
          }
        },
      });
    } catch (error) {
      if (error instanceof BadRequestException) {
        res.status(400).json({
          error: 'Bad Request',
          message: error.message,
        });
      } else {
        throw new InternalServerErrorException('Failed to start video stream');
      }
    }
  }

  @Get('health')
  async checkAvailability(
    @Query('type') type: string,
    @Query('index') index?: string,
    @Res() res?: Response
  ): Promise<void> {
    try {
      const cameraType = this.getCameraType(type);
      const cameraIndex = index !== undefined ? parseInt(index, 10) : undefined;

      if (cameraIndex !== undefined && isNaN(cameraIndex)) {
        throw new BadRequestException('Invalid camera index');
      }

      this.checkCameraAvailabilityUseCase
        .execute(cameraType, cameraIndex)
        .subscribe({
          next: (isAvailable) => {
            res.status(isAvailable ? 200 : 503).json({
              status: isAvailable ? 'healthy' : 'unavailable',
              camera: isAvailable ? 'connected' : 'disconnected',
              type: cameraType,
              timestamp: new Date().toISOString(),
            });
          },
          error: (error) => {
            res.status(503).json({
              status: 'error',
              camera: 'unknown',
              type: cameraType,
              timestamp: new Date().toISOString(),
              error: error.message,
            });
          },
        });
    } catch (error) {
      if (error instanceof BadRequestException) {
        res.status(400).json({
          error: 'Bad Request',
          message: error.message,
        });
      } else {
        throw new InternalServerErrorException(
          'Failed to check camera availability'
        );
      }
    }
  }
}
