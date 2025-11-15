import { Injectable, Logger } from '@nestjs/common';
import { spawn, ChildProcess } from 'child_process';
import { Readable } from 'stream';

export interface GridCameraConfig {
  devicePath: string;
  position: 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';
}

@Injectable()
export class MultiCameraGridService {
  private readonly logger = new Logger(MultiCameraGridService.name);
  private activeGridProcess: ChildProcess | null = null;

  createGridStream(cameras: GridCameraConfig[]): Readable {
    if (this.activeGridProcess && !this.activeGridProcess.killed)
      this.activeGridProcess.kill('SIGKILL');

    const inputs: string[] = [];
    const filterInputs: string[] = [];

    cameras.forEach((camera, index) => {
      inputs.push(
        '-f',
        'v4l2',
        '-input_format',
        'mjpeg',
        '-video_size',
        '640x480',
        '-framerate',
        '15',
        '-i',
        camera.devicePath
      );
      filterInputs.push(`[${index}:v]`);
    });

    // Construir el filtro complejo para la cuadrícula 2x2
    let filterComplex = '';

    // Escalar cada input a 640x480 y agregar padding negro si es necesario
    cameras.forEach((_, index) => {
      filterComplex += `[${index}:v]scale=640:480,setsar=1[scaled${index}];`;
    });

    // Crear la cuadrícula 2x2
    // Top row: cámara 0 (izq) y cámara 1 (der) o espacio negro
    if (cameras.length >= 2) {
      filterComplex += `[scaled0][scaled1]hstack=inputs=2[top];`;
    } else {
      // Solo una cámara en top-left, agregar espacio negro a la derecha
      filterComplex += `[scaled0]pad=1280:480:0:0:black[top];`;
    }

    // Bottom row: cámara 2 (izq) y cámara 3 (der) o espacio negro
    if (cameras.length >= 4) {
      filterComplex += `[scaled2][scaled3]hstack=inputs=2[bottom];`;
    } else if (cameras.length === 3) {
      // Tres cámaras: agregar espacio negro en bottom-right
      filterComplex += `[scaled2]pad=1280:480:0:0:black[bottom];`;
    } else {
      // Una o dos cámaras: crear fila inferior completamente negra
      filterComplex += `color=black:1280x480:d=1[bottom];`;
    }

    // Combinar las dos filas verticalmente
    filterComplex += `[top][bottom]vstack=inputs=2[out]`;

    this.logger.debug(`FFmpeg filter: ${filterComplex}`);

    // Comando ffmpeg completo
    const ffmpegArgs = [
      '-loglevel',
      'error',
      ...inputs,
      '-filter_complex',
      filterComplex,
      '-map',
      '[out]',
      '-f',
      'mpjpeg',
      '-q:v',
      '5',
      '-',
    ];

    this.logger.debug(`FFmpeg command: ffmpeg ${ffmpegArgs.join(' ')}`);

    const ffmpeg = spawn('ffmpeg', ffmpegArgs, {
      stdio: ['ignore', 'pipe', 'pipe'],
    });

    this.activeGridProcess = ffmpeg;

    ffmpeg.stderr.on('data', (data) => {
      const errorMsg = data.toString();
      if (
        !errorMsg.includes('Broken pipe') &&
        (errorMsg.includes('Error') || errorMsg.includes('error'))
      ) {
        this.logger.error(`FFmpeg grid error: ${errorMsg}`);
      }
    });

    ffmpeg.on('error', (error) => {
      this.logger.error(`FFmpeg grid process error: ${error.message}`);
    });

    ffmpeg.on('close', (code) => {
      this.activeGridProcess = null;
      if (code !== 0 && code !== null) {
        this.logger.warn(`FFmpeg grid closed with code ${code}`);
      } else {
        this.logger.log('FFmpeg grid stream closed normally');
      }
    });

    return ffmpeg.stdout;
  }

  stopGridStream(): void {
    if (this.activeGridProcess && !this.activeGridProcess.killed) {
      this.logger.log('Stopping grid stream');
      this.activeGridProcess.kill('SIGKILL');
      this.activeGridProcess = null;
    }
  }

  isGridActive(): boolean {
    return this.activeGridProcess !== null && !this.activeGridProcess.killed;
  }
}
