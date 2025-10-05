import {
  Controller,
  Get,
  Res,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { Response } from 'express';
import { CameraService } from './camera.service';

@Controller('/camera')
export class CameraController {
  private readonly logger = new Logger(CameraController.name);

  constructor(private readonly cameraService: CameraService) {}

  @Get('photo')
  async capturePhoto(@Res() res: Response): Promise<void> {
    try {
      this.logger.debug('Photo capture request received');

      this.cameraService.capturePhoto().subscribe({
        next: (photoBuffer: Buffer) => {
          res.set({
            'Content-Type': 'image/jpeg',
            'Content-Length': photoBuffer.length.toString(),
            'Cache-Control': 'no-cache',
          });
          res.end(photoBuffer);
          this.logger.debug('Photo response sent successfully');
        },
        error: (error) => {
          this.logger.error('Error in photo capture', error.message);
          if (!res.headersSent) {
            res.status(500).json({
              error: 'Failed to capture photo',
              message: 'Camera service unavailable',
            });
          }
        },
      });
    } catch (error) {
      this.logger.error('Unexpected error in photo capture', error);
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

      this.cameraService.getVideoStream().subscribe({
        next: (stream: NodeJS.ReadableStream) => {
          stream.pipe(res);
        },
        error: (error) => {
          this.logger.error('Error in video stream', error.message);
          if (!res.headersSent) {
            res.status(500).json({
              error: 'Failed to start video stream',
              message: 'Camera service unavailable',
            });
          }
        },
      });

      res.on('close', () => {
        this.logger.debug('Client disconnected from video stream');
      });
    } catch (error) {
      this.logger.error('Unexpected error in video stream', error);
      throw new InternalServerErrorException('Failed to start video stream');
    }
  }

  @Get('health')
  async checkHealth(): Promise<{ status: string; camera: boolean }> {
    this.logger.debug('Camera health check requested');

    const cameraAvailable = await this.cameraService.checkCameraHealth();

    return {
      status: cameraAvailable ? 'ok' : 'degraded',
      camera: cameraAvailable,
    };
  }
}
