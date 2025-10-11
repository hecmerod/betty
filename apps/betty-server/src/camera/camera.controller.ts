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
      this.cameraService.capturePhoto().subscribe({
        next: (photoBuffer: Buffer) => {
          res.set({
            'Content-Type': 'image/jpeg',
            'Content-Length': photoBuffer.length.toString(),
            'Cache-Control': 'no-cache',
          });
          res.end(photoBuffer);
        },
        error: () => {
          if (!res.headersSent) {
            res.status(500).json({
              error: 'Failed to capture photo',
              message: 'Camera service unavailable',
            });
          }
        },
      });
    } catch {
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
        error: () => {
          if (!res.headersSent) {
            res.status(500).json({
              error: 'Failed to start video stream',
              message: 'Camera service unavailable',
            });
          }
        },
      });
    } catch {
      throw new InternalServerErrorException('Failed to start video stream');
    }
  }
}
