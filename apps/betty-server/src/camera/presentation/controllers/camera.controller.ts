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
import { CheckCameraAvailabilityUseCase } from '../../application/use-cases/check-camera-availability/check-camera-availability.use-case';
import { CameraType } from '../../domain/enums/camera-type.enum';

@Controller('/camera')
export class CameraController {
  constructor(
    private readonly capturePhotoUseCase: CapturePhotoUseCase,
    private readonly getVideoStreamUseCase: GetVideoStreamUseCase,
    private readonly checkCameraAvailabilityUseCase: CheckCameraAvailabilityUseCase
  ) {}

  private getCameraType(type?: string): CameraType {
    if (!type) {
      return CameraType.EXTERNAL; // Default
    }

    const upperType = type.toUpperCase();
    if (upperType === 'EXTERNAL') {
      return CameraType.EXTERNAL;
    }
    if (upperType === 'INTERNAL') {
      return CameraType.INTERNAL;
    }

    throw new BadRequestException(
      'Invalid camera type. Use "internal" or "external"'
    );
  }

  @Get('photo')
  async capturePhoto(
    @Query('type') type: string,
    @Res() res: Response
  ): Promise<void> {
    try {
      const cameraType = this.getCameraType(type);

      this.capturePhotoUseCase.execute(cameraType).subscribe({
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
    @Res() res: Response
  ): Promise<void> {
    try {
      const cameraType = this.getCameraType(type);

      res.set({
        'Content-Type': 'multipart/x-mixed-replace; boundary=frame',
        'Cache-Control': 'no-cache',
        Connection: 'keep-alive',
        Pragma: 'no-cache',
      });

      const subscription = this.getVideoStreamUseCase
        .execute(cameraType)
        .subscribe({
          next: (videoStream) => {
            videoStream.stream.pipe(res);

            // Limpiar cuando el cliente se desconecta
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
    @Res() res: Response
  ): Promise<void> {
    try {
      const cameraType = this.getCameraType(type);

      this.checkCameraAvailabilityUseCase.execute(cameraType).subscribe({
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
