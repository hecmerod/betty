import { Injectable, Logger } from '@nestjs/common';
import { Readable } from 'stream';
import { ObjectDetectionService } from './object-detection.service';
import { DetectionResult } from '../../domain/entities/detection.entity';

interface DetectionFrame {
  frame: Buffer;
  timestamp: Date;
  detections: DetectionResult;
}

@Injectable()
export class VideoDetectionService {
  private readonly logger = new Logger(VideoDetectionService.name);
  private detectionIntervalMs: number;
  private frameCount: number = 0;

  constructor(private readonly detectionService: ObjectDetectionService) {
    // Detectar cada N frames (por defecto cada 60 frames ~2 segundos a 30fps)
    const detectionInterval = parseInt(
      process.env.DETECTION_FRAME_INTERVAL || '60'
    );
    this.detectionIntervalMs = detectionInterval;
  }

  /**
   * Procesa un stream de video y aplica detección de objetos periódicamente
   */
  processVideoStream(
    videoStream: Readable,
    onDetection?: (result: DetectionResult) => void
  ): Readable {
    const outputStream = new Readable({
      read() {
        // No-op, el stream es push-based
      },
    });

    let buffer = Buffer.alloc(0);
    let lastDetectionFrame = 0;

    videoStream.on('data', async (chunk: Buffer) => {
      // Pasar datos directamente al output
      outputStream.push(chunk);

      // Acumular frames MJPEG
      buffer = Buffer.concat([buffer, chunk]);

      // Intentar extraer un frame completo (JPEG)
      const frameStart = buffer.indexOf(Buffer.from([0xff, 0xd8])); // JPEG SOI
      const frameEnd = buffer.indexOf(Buffer.from([0xff, 0xd9]), 2); // JPEG EOI

      if (frameStart !== -1 && frameEnd !== -1) {
        const frame = buffer.slice(frameStart, frameEnd + 2);
        buffer = buffer.slice(frameEnd + 2);

        this.frameCount++;

        // Ejecutar detección cada N frames
        if (this.frameCount - lastDetectionFrame >= this.detectionIntervalMs) {
          lastDetectionFrame = this.frameCount;

          try {
            const result = await this.detectionService.detectObjects(frame);

            if (result.totalDetections > 0) {
              this.logger.log(
                `🚨 Detected ${result.totalDetections} person(s) in frame ${this.frameCount}`
              );

              if (onDetection) {
                onDetection(result);
              }
            }
          } catch (error) {
            this.logger.error(`Detection error: ${error.message}`);
          }
        }
      }
    });

    videoStream.on('error', (error) => {
      this.logger.error(`Video stream error: ${error.message}`);
      outputStream.destroy(error);
    });

    videoStream.on('end', () => {
      this.logger.log('Video stream ended');
      outputStream.push(null);
    });

    return outputStream;
  }

  /**
   * Detecta objetos en un frame individual
   */
  async detectInFrame(frameBuffer: Buffer): Promise<DetectionResult> {
    return this.detectionService.detectObjects(frameBuffer);
  }

  /**
   * Extrae un frame de un stream de video para análisis
   */
  async extractFrame(videoStream: Readable): Promise<Buffer> {
    return new Promise((resolve, reject) => {
      let buffer = Buffer.alloc(0);
      let resolved = false;

      const timeout = setTimeout(() => {
        if (!resolved) {
          resolved = true;
          reject(new Error('Frame extraction timeout'));
        }
      }, 5000);

      videoStream.on('data', (chunk: Buffer) => {
        if (resolved) return;

        buffer = Buffer.concat([buffer, chunk]);

        // Buscar un frame JPEG completo
        const frameStart = buffer.indexOf(Buffer.from([0xff, 0xd8]));
        const frameEnd = buffer.indexOf(Buffer.from([0xff, 0xd9]), 2);

        if (frameStart !== -1 && frameEnd !== -1) {
          const frame = buffer.slice(frameStart, frameEnd + 2);
          resolved = true;
          clearTimeout(timeout);
          resolve(frame);
        }
      });

      videoStream.on('error', (error) => {
        if (!resolved) {
          resolved = true;
          clearTimeout(timeout);
          reject(error);
        }
      });
    });
  }

  resetFrameCount(): void {
    this.frameCount = 0;
  }
}
