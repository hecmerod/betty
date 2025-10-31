import {
  Injectable,
  InternalServerErrorException,
  Logger,
  OnModuleInit,
} from '@nestjs/common';
import { Observable, from, catchError } from 'rxjs';
import { Readable } from 'stream';
import { spawn, exec, ChildProcess } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';

const execAsync = promisify(exec);

@Injectable()
export class UsbCameraAdapter implements OnModuleInit {
  private readonly logger = new Logger(UsbCameraAdapter.name);
  private activeStream: ChildProcess | null = null;
  private devicePath: string | null = null;

  async onModuleInit() {
    this.devicePath = await this.findUsbCamera();
  }

  private async findUsbCamera(): Promise<string> {
    const { stdout } = await execAsync(
      'v4l2-ctl --list-devices 2>/dev/null || echo ""'
    );

    if (!stdout) throw new Error('v4l2-ctl not available');

    const lines = stdout.split('\n');
    let isUsbCamera = false;

    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];

      if (
        line.toLowerCase().includes('usb') ||
        line.includes('HD 2MP WEBCAM') ||
        line.includes('USB Camera')
      ) {
        isUsbCamera = true;
        continue;
      }

      if (isUsbCamera && line.includes('/dev/video')) {
        const match = line.match(/\/dev\/video\d+/);
        if (match) {
          this.logger.log(`Found USB camera at ${match[0]}`);
          return match[0];
        }
      }
      if (
        isUsbCamera &&
        !line.startsWith('\t') &&
        !line.startsWith(' ') &&
        line.trim()
      ) {
        isUsbCamera = false;
      }
    }
  }

  private async killExistingProcesses(devicePath: string): Promise<void> {
    try {
      // Matar cualquier proceso ffmpeg usando este dispositivo
      await execAsync(`pkill -9 -f "ffmpeg.*${devicePath}" || true`).catch(
        () => {
          // Ignorar si no hay procesos
        }
      );
      // Pequeña pausa para asegurar que el dispositivo se libere
      await new Promise((resolve) => setTimeout(resolve, 100));
    } catch (error) {
      this.logger.warn('Error killing existing processes', error);
    }
  }

  requestPhoto(): Observable<Buffer> {
    return from(
      (async () => {
        const devicePath = this.devicePath;
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

  requestVideoStream(): Observable<Readable> {
    return new Observable((observer) => {
      let isClientDisconnected = false;

      (async () => {
        try {
          const devicePath = this.devicePath;

          // Limpiar streams anteriores
          if (this.activeStream && !this.activeStream.killed) {
            this.logger.log('Killing previous stream');
            this.activeStream.kill('SIGKILL');
            await new Promise((resolve) => setTimeout(resolve, 200));
          }

          await this.killExistingProcesses(devicePath);

          this.logger.log(`Starting FFmpeg stream from ${devicePath}`);

          // Usar ffmpeg para streaming de video desde USB
          const ffmpeg = spawn(
            'ffmpeg',
            [
              '-loglevel',
              'error', // Solo mostrar errores
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
            ],
            {
              stdio: ['ignore', 'pipe', 'pipe'],
            }
          );

          this.activeStream = ffmpeg;

          observer.next(ffmpeg.stdout);

          ffmpeg.stderr.on('data', (data) => {
            const errorMsg = data.toString();

            // Ignorar errores de "Broken pipe" que son normales cuando el cliente se desconecta
            if (errorMsg.includes('Broken pipe')) {
              isClientDisconnected = true;
              return;
            }

            // Solo loguear errores importantes que no sean desconexiones normales
            if (
              (errorMsg.includes('Error') ||
                errorMsg.includes('error') ||
                errorMsg.includes('busy')) &&
              !isClientDisconnected
            ) {
              this.logger.error(`FFmpeg error: ${errorMsg}`);
            }
          });

          ffmpeg.on('error', (error) => {
            if (!isClientDisconnected) {
              this.logger.error(`FFmpeg process error: ${error.message}`);
              observer.error(
                new InternalServerErrorException(
                  `FFmpeg process error: ${error.message}`
                )
              );
            }
          });

          ffmpeg.on('close', (code) => {
            this.activeStream = null;

            // No loguear si fue una desconexión normal del cliente
            if (isClientDisconnected) {
              observer.complete();
              return;
            }

            this.logger.log(`FFmpeg closed with code ${code}`);

            if (code !== 0 && code !== null) {
              observer.error(
                new InternalServerErrorException(
                  `FFmpeg exited with code ${code}`
                )
              );
            } else {
              observer.complete();
            }
          });

          // Cleanup cuando se desuscribe
          return () => {
            if (ffmpeg && !ffmpeg.killed) {
              isClientDisconnected = true;
              this.logger.debug('Cleaning up FFmpeg stream');
              ffmpeg.kill('SIGKILL');
              this.activeStream = null;
            }
          };
        } catch (error) {
          observer.error(
            new InternalServerErrorException(
              `Failed to start video stream: ${error.message}`
            )
          );
        }
      })();
    });
  }

  checkAvailability(): Observable<boolean> {
    return from(
      (async () => {
        try {
          const devicePath = this.devicePath;
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
