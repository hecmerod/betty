import {
  Injectable,
  InternalServerErrorException,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import { Observable, from, catchError } from 'rxjs';
import { Readable } from 'stream';
import { exec, spawn, ChildProcess } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';
import {
  MultiCameraGridService,
  GridCameraConfig,
} from '../services/multi-camera-grid.service';
import { UsbCameraDetectorService } from '../services/usb-camera-detector.service';
import { CameraType } from '../../domain/enums/camera-type.enum';

const execAsync = promisify(exec);

@Injectable()
export class UsbCameraAdapter {
  private readonly logger = new Logger(UsbCameraAdapter.name);
  private activeGridProcess: ChildProcess | null = null;

  constructor(
    private readonly gridService: MultiCameraGridService,
    private readonly cameraDetector: UsbCameraDetectorService
  ) {}

  private getDevicePath(cameraType: CameraType, cameraIndex?: number): string {
    if (cameraType === CameraType.INTERNAL) {
      const internalCamera = this.cameraDetector.getInternalCamera();

      return internalCamera;
    }

    const externalCameras = this.cameraDetector.getExternalCameras();

    const index = cameraIndex ?? 0;
    if (index < 0 || index >= externalCameras.length) {
      throw new BadRequestException(
        `Camera index ${index} out of range. Available: 0-${
          externalCameras.length - 1
        }`
      );
    }

    return externalCameras[index];
  }

  private async killExistingProcesses(devicePath: string): Promise<void> {
    try {
      await execAsync(`pkill -9 -f "ffmpeg.*${devicePath}" || true`).catch(
        () => {
          // Ignorar si no hay procesos
        }
      );
    } catch (error) {
      this.logger.warn('Error killing existing processes', error);
    }
  }

  requestPhoto(
    cameraType: CameraType,
    cameraIndex?: number
  ): Observable<Buffer> {
    return from(
      (async () => {
        const devicePath = this.getDevicePath(cameraType, cameraIndex);
        this.logger.log(`📸 Capturing photo from ${devicePath}`);

        await this.killExistingProcesses(devicePath);

        // Usar ffmpeg para capturar una foto (más compatible que fswebcam)
        const result = await execAsync(
          `ffmpeg -y -f v4l2 -input_format mjpeg -video_size 1280x720 -i ${devicePath} -frames:v 1 -f image2pipe -vcodec mjpeg - 2>/dev/null`
        );

        return Buffer.from(result.stdout);
      })()
    ).pipe(
      catchError((error) => {
        throw new InternalServerErrorException(
          `Failed to capture photo from USB camera: ${error.message}`
        );
      })
    );
  }

  requestVideoStream(
    cameraType: CameraType,
    cameraIndex?: number
  ): Observable<Readable> {
    return new Observable((observer) => {
      try {
        const devicePath = this.getDevicePath(cameraType, cameraIndex);

        const ffmpegArgs = [
          '-loglevel',
          'error',
          '-f',
          'v4l2',
          '-input_format',
          'mjpeg',
          '-video_size',
          '1280x720',
          '-framerate',
          '30',
          '-i',
          devicePath,
          '-f',
          'mpjpeg',
          '-q:v',
          '5',
          '-',
        ];

        const ffmpeg = spawn('ffmpeg', ffmpegArgs, {
          stdio: ['ignore', 'pipe', 'pipe'],
        });

        observer.next(ffmpeg.stdout);

        ffmpeg.on('close', () => {
          observer.complete();
        });

        ffmpeg.on('error', (error) => {
          observer.error(
            new InternalServerErrorException(
              `Video stream error: ${error.message}`
            )
          );
        });

        return () => {
          if (ffmpeg && !ffmpeg.killed) {
            ffmpeg.kill('SIGKILL');
          }
        };
      } catch (error) {
        observer.error(
          new InternalServerErrorException(
            `Failed to start video stream: ${error.message}`
          )
        );
      }
    });
  }

  requestGridVideoStream(): Observable<Readable> {
    return new Observable((observer) => {
      try {
        if (this.activeGridProcess && !this.activeGridProcess.killed) {
          this.activeGridProcess.kill('SIGKILL');
        }

        const positions = [
          'top-left',
          'top-right',
          'bottom-left',
          'bottom-right',
        ] as const;

        const externalCameras = this.cameraDetector.getExternalCameras();
        const cameraConfigs: GridCameraConfig[] = externalCameras
          .slice(0, 4)
          .map((devicePath, index) => ({
            devicePath,
            position: positions[index],
          }));

        const gridConfig = this.gridService.generateGridConfig(cameraConfigs);

        const ffmpegArgs = [
          '-loglevel',
          'error',
          ...gridConfig.inputs,
          '-filter_complex',
          gridConfig.filterComplex,
          ...gridConfig.outputArgs,
        ];

        const ffmpeg = spawn('ffmpeg', ffmpegArgs, {
          stdio: ['ignore', 'pipe', 'pipe'],
        });

        this.activeGridProcess = ffmpeg;

        observer.next(ffmpeg.stdout);

        ffmpeg.on('close', () => {
          this.activeGridProcess = null;
          observer.complete();
        });

        ffmpeg.on('error', (error) => {
          this.activeGridProcess = null;
          observer.error(
            new InternalServerErrorException(
              `Grid stream error: ${error.message}`
            )
          );
        });

        return () => {
          if (this.activeGridProcess && !this.activeGridProcess.killed) {
            this.activeGridProcess.kill('SIGKILL');
            this.activeGridProcess = null;
          }
        };
      } catch (error) {
        observer.error(
          new InternalServerErrorException(
            `Failed to start grid video stream: ${error.message}`
          )
        );
      }
    });
  }

  checkAvailability(
    cameraType: CameraType,
    cameraIndex?: number
  ): Observable<boolean> {
    return from(
      (async () => {
        try {
          const devicePath = this.getDevicePath(cameraType, cameraIndex);
          await fs.promises.access(devicePath, fs.constants.R_OK);

          // Verificar que no esté ocupado
          const { stdout } = await execAsync(
            `lsof ${devicePath} 2>/dev/null || echo "free"`
          );
          const isFree = stdout.includes('free');
          return isFree;
        } catch {
          return false;
        }
      })()
    ).pipe(
      catchError(() => {
        return [false];
      })
    );
  }
}
