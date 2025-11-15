import {
  Injectable,
  InternalServerErrorException,
  Logger,
  OnModuleInit,
} from '@nestjs/common';
import { Observable, from, catchError } from 'rxjs';
import { Readable } from 'stream';
import { exec } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';
import { MultiCameraGridService } from '../services/multi-camera-grid.service';

const execAsync = promisify(exec);

@Injectable()
export class UsbCameraAdapter implements OnModuleInit {
  private readonly logger = new Logger(UsbCameraAdapter.name);
  private usbCameras: string[] = [];
  private currentCameraIndex = 0;

  constructor(private readonly gridService: MultiCameraGridService) {}

  async onModuleInit() {
    this.usbCameras = await this.findAllUsbCameras();

    if (this.usbCameras.length == 0) throw new Error('No USB cameras found');

    this.logger.log(
      `📹 Initialized with ${
        this.usbCameras.length
      } USB cameras: ${this.usbCameras.join(', ')}`
    );
  }

  private async findAllUsbCameras(): Promise<string[]> {
    const { stdout } = await execAsync(
      'v4l2-ctl --list-devices 2>/dev/null || echo ""'
    );

    const cameras: string[] = [];
    const lines = stdout.split('\n');
    let isUsbCamera = false;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      // Detectar línea de dispositivo USB (excluir cámaras Raspberry Pi)
      if (
        (line.toLowerCase().includes('usb') ||
          line.includes('HD 2MP WEBCAM') ||
          line.includes('USB Camera')) &&
        !line.toLowerCase().includes('bcm') &&
        !line.toLowerCase().includes('mmal')
      ) {
        isUsbCamera = true;
        continue;
      }

      if (isUsbCamera && line.includes('/dev/video')) {
        const match = line.match(/\/dev\/video\d+/);
        if (match && !cameras.includes(match[0])) {
          const isCapture = await this.isVideoCaptureDevice(match[0]);
          if (isCapture) {
            cameras.push(match[0]);
          }
        }
      }

      if (
        isUsbCamera &&
        !line.startsWith('\t') &&
        !line.startsWith(' ') &&
        line.trim()
      )
        isUsbCamera = false;
    }

    return cameras;
  }

  private async isVideoCaptureDevice(devicePath: string): Promise<boolean> {
    try {
      const { stdout } = await execAsync(
        `v4l2-ctl --device=${devicePath} --list-formats 2>/dev/null || echo ""`
      );

      const hasValidFormat =
        stdout.includes('MJPG') ||
        stdout.includes('YUYV') ||
        stdout.includes('H264') ||
        stdout.includes('RGB');

      return hasValidFormat;
    } catch {
      return false;
    }
  }

  private getCurrentCamera(): string {
    return this.usbCameras[this.currentCameraIndex % this.usbCameras.length];
  }

  private rotateCamera(): void {
    this.currentCameraIndex =
      (this.currentCameraIndex + 1) % this.usbCameras.length;
  }

  getAvailableCameras(): string[] {
    return [...this.usbCameras];
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

  requestPhoto(): Observable<Buffer> {
    return from(
      (async () => {
        const devicePath = this.getCurrentCamera();
        this.logger.log(`📸 Capturing photo from ${devicePath}`);

        await this.killExistingProcesses(devicePath);

        // Usar ffmpeg para capturar una foto (más compatible que fswebcam)
        const result = await execAsync(
          `ffmpeg -y -f v4l2 -input_format mjpeg -video_size 1280x720 -i ${devicePath} -frames:v 1 -f image2pipe -vcodec mjpeg - 2>/dev/null`
        );

        // Rotar a la siguiente cámara para la próxima captura
        this.rotateCamera();

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

  requestVideoStream(): Observable<Readable> {
    return new Observable((observer) => {
      try {
        const positions = [
          'top-left',
          'top-right',
          'bottom-left',
          'bottom-right',
        ] as const;
        const cameraConfigs = this.usbCameras
          .slice(0, 4)
          .map((devicePath, index) => ({
            devicePath,
            position: positions[index],
          }));

        const gridStream = this.gridService.createGridStream(cameraConfigs);

        observer.next(gridStream);

        gridStream.on('end', () => {
          observer.complete();
        });

        gridStream.on('error', (error) => {
          this.logger.error(`Grid stream error: ${error.message}`);
          observer.error(
            new InternalServerErrorException(
              `Grid stream error: ${error.message}`
            )
          );
        });

        return () => {
          this.gridService.stopGridStream();
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

  checkAvailability(): Observable<boolean> {
    return from(
      (async () => {
        try {
          // Verificar que al menos una cámara USB esté disponible
          if (this.usbCameras.length === 0) {
            return false;
          }

          // Verificar la primera cámara como prueba rápida
          const devicePath = this.usbCameras[0];
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
