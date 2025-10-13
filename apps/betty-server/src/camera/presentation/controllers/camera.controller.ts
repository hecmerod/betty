import {
  Controller,
  Get,
  Res,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { Response } from 'express';
import { CapturePhotoUseCase } from '../../application/use-cases/capture-photo/capture-photo.use-case';
import { GetVideoStreamUseCase } from '../../application/use-cases/get-video-stream/get-video-stream.use-case';
import { CheckCameraAvailabilityUseCase } from '../../application/use-cases/check-camera-availability/check-camera-availability.use-case';

@Controller('/camera')
export class CameraController {
  private readonly logger = new Logger(CameraController.name);

  constructor(
    private readonly capturePhotoUseCase: CapturePhotoUseCase,
    private readonly getVideoStreamUseCase: GetVideoStreamUseCase,
    private readonly checkCameraAvailabilityUseCase: CheckCameraAvailabilityUseCase
  ) {}

  @Get('photo')
  async capturePhoto(@Res() res: Response): Promise<void> {
    try {
      this.capturePhotoUseCase.execute().subscribe({
        next: (photo) => {
          res.set({
            'Content-Type': photo.getMimeType(),
            'Content-Length': photo.getSize().toString(),
            'Cache-Control': 'no-cache',
          });
          res.end(photo.data);
        },
        error: (error) => {
          this.logger.error('Error capturing photo', error.message);
          if (!res.headersSent) {
            res.status(500).json({
              error: 'Failed to capture photo',
              message: 'Camera service unavailable',
            });
          }
        },
      });
    } catch (error) {
      this.logger.error('Unexpected error in capturePhoto', error);
      throw new InternalServerErrorException('Failed to capture photo');
    }
  }

  @Get('video')
  async getVideoStream(@Res() res: Response): Promise<void> {
    try {
      res.set({
        'Content-Type': 'multipart/x-mixed-replace; boundary=frame',
        'Cache-Control': 'no-cache',
        Connection: 'keep-alive',
        Pragma: 'no-cache',
      });

      this.getVideoStreamUseCase.execute().subscribe({
        next: (videoStream) => {
          videoStream.stream.pipe(res);
        },
        error: (error) => {
          this.logger.error('Error starting video stream', error.message);
          if (!res.headersSent) {
            res.status(500).json({
              error: 'Failed to start video stream',
              message: 'Camera service unavailable',
            });
          }
        },
      });
    } catch (error) {
      this.logger.error('Unexpected error in getVideoStream', error);
      throw new InternalServerErrorException('Failed to start video stream');
    }
  }

  @Get('health')
  async checkAvailability(@Res() res: Response): Promise<void> {
    try {
      this.checkCameraAvailabilityUseCase.execute().subscribe({
        next: (isAvailable) => {
          res.status(isAvailable ? 200 : 503).json({
            status: isAvailable ? 'healthy' : 'unavailable',
            camera: isAvailable ? 'connected' : 'disconnected',
            timestamp: new Date().toISOString(),
          });
        },
        error: (error) => {
          this.logger.error(
            'Error checking camera availability',
            error.message
          );
          res.status(503).json({
            status: 'error',
            camera: 'unknown',
            timestamp: new Date().toISOString(),
            error: error.message,
          });
        },
      });
    } catch (error) {
      this.logger.error('Unexpected error in checkAvailability', error);
      throw new InternalServerErrorException(
        'Failed to check camera availability'
      );
    }
  }
}
