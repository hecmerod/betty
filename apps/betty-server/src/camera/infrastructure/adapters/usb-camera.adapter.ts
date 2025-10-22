import {
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { Observable, from, catchError } from 'rxjs';
import { Readable } from 'stream';
import { spawn, exec, ChildProcess } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';

const execAsync = promisify(exec);

@Injectable()
export class UsbCameraAdapter {
  private readonly logger = new Logger(UsbCameraAdapter.name);
  private readonly devicePath: string;
  private activeStream: ChildProcess | null = null;

  constructor() {
    // /dev/video8 es la cámara USB (HD 2MP WEBCAM)
    // /dev/video0 es la cámara CSI (usada por betty-camera)
    this.devicePath = process.env.USB_CAMERA_DEVICE || '/dev/video8';
  }

  private async killExistingProcesses(): Promise<void> {
    try {
      // Matar cualquier proceso ffmpeg usando este dispositivo
      await execAsync(`pkill -9 -f "ffmpeg.*${this.devicePath}" || true`).catch(
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
        await this.killExistingProcesses();
        const result = await execAsync(
          `fswebcam -d ${this.devicePath} -r 1280x720 --no-banner --jpeg 95 - 2>/dev/null`
        );
        // fswebcam con '-' como salida escribe a stdout
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
          // Limpiar streams anteriores
          if (this.activeStream && !this.activeStream.killed) {
            this.logger.log('Killing previous stream');
            this.activeStream.kill('SIGKILL');
            await new Promise((resolve) => setTimeout(resolve, 200));
          }

          await this.killExistingProcesses();

          this.logger.log('Starting FFmpeg stream');

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
              this.devicePath,
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
              this.logger.debug('FFmpeg closed after client disconnect');
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
          await fs.promises.access(this.devicePath, fs.constants.R_OK);
          // Verificar que no esté ocupado
          const { stdout } = await execAsync(
            `lsof ${this.devicePath} 2>/dev/null || echo "free"`
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
