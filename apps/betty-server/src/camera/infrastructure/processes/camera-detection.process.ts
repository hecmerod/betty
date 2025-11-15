import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnApplicationBootstrap,
} from '@nestjs/common';
import { Readable, PassThrough } from 'stream';
import { UsbCameraAdapter } from '../adapters/usb-camera.adapter';
import { ImageObjectDetectionService } from '../services/image-object-detection.service';
import { CameraType } from '../../domain/enums/camera-type.enum';

@Injectable()
export class CameraDetectionProcess
  implements OnApplicationBootstrap, OnModuleDestroy
{
  private readonly logger = new Logger(CameraDetectionProcess.name);
  private sourceStream: Readable | null = null;
  private consumers: PassThrough[] = [];
  private frameCount = 0;
  private detectionInterval = 60;
  private lastDetectionFrame = 0;

  constructor(
    private readonly usbCameraAdapter: UsbCameraAdapter,
    private readonly imageObjectDetection: ImageObjectDetectionService
  ) {}

  onApplicationBootstrap() {
    this.startInternalCameraStream();
  }

  private startInternalCameraStream(): void {
    this.logger.log('🎥 Iniciando stream de cámara interna con detección...');

    this.usbCameraAdapter.requestVideoStream(CameraType.INTERNAL).subscribe({
      next: (stream) => {
        this.logger.log('✅ Stream recibido del adapter');
        this.sourceStream = stream;
        this.setupStreamHandlers();
      },
      error: (error) => {
        this.logger.error(`❌ Error iniciando stream: ${error.message}`);
        setTimeout(() => this.startInternalCameraStream(), 2000);
      },
    });
  }

  onModuleDestroy() {
    this.stopInternalCameraStream();
  }

  private setupStreamHandlers(): void {
    if (!this.sourceStream) return;

    let buffer = Buffer.alloc(0);
    let dataReceived = false;

    this.sourceStream.on('data', async (chunk: Buffer) => {
      if (!dataReceived) dataReceived = true;

      this.consumers.forEach((consumer) => {
        if (!consumer.destroyed) {
          consumer.write(chunk);
        }
      });

      buffer = Buffer.concat([buffer, chunk]);

      const frameStart = buffer.indexOf(Buffer.from([0xff, 0xd8])); // JPEG SOI
      const frameEnd = buffer.indexOf(Buffer.from([0xff, 0xd9]), 2); // JPEG EOI

      if (frameStart !== -1 && frameEnd !== -1) {
        const frame = buffer.slice(frameStart, frameEnd + 2);
        buffer = buffer.slice(frameEnd + 2);

        this.frameCount++;

        if (
          this.frameCount - this.lastDetectionFrame >=
          this.detectionInterval
        ) {
          this.lastDetectionFrame = this.frameCount;
          const detections = await this.imageObjectDetection.detectObjects(
            frame
          );
          if (detections.length > 0) this.logger.log(detections);
        }
      }
    });

    this.sourceStream.on('error', () => {
      setTimeout(() => this.restartStream(), 2000);
    });

    this.sourceStream.on('end', () => {
      this.consumers.forEach((consumer) => consumer.end());
    });
  }

  private async restartStream(): Promise<void> {
    this.stopInternalCameraStream();
    await this.startInternalCameraStream();
  }

  private stopInternalCameraStream(): void {
    if (this.sourceStream) {
      this.sourceStream.destroy();
      this.sourceStream = null;
    }

    this.consumers.forEach((consumer) => {
      if (!consumer.destroyed) {
        consumer.destroy();
      }
    });
    this.consumers = [];
  }

  getStream(): Readable {
    if (!this.sourceStream || this.sourceStream.destroyed) {
      this.logger.warn('⚠️ Stream no disponible, creando stream on-demand');
      return this.createOnDemandStream();
    }

    const consumerStream = new PassThrough();
    this.consumers.push(consumerStream);

    this.logger.log(
      `📺 Nuevo consumidor conectado (Total: ${this.consumers.length})`
    );

    consumerStream.on('close', () => {
      const index = this.consumers.indexOf(consumerStream);
      if (index > -1) {
        this.consumers.splice(index, 1);
        this.logger.log(
          `👋 Consumidor desconectado (Restantes: ${this.consumers.length})`
        );
      }
    });

    return consumerStream;
  }

  private createOnDemandStream(): Readable {
    const passThrough = new PassThrough();

    this.usbCameraAdapter.requestVideoStream(CameraType.INTERNAL).subscribe({
      next: (stream) => {
        stream.pipe(passThrough);
      },
      error: (error) => {
        this.logger.error(
          `❌ Error creando stream on-demand: ${error.message}`
        );
        passThrough.destroy(error);
      },
    });

    return passThrough;
  }

  isStreamActive(): boolean {
    return this.sourceStream !== null && !this.sourceStream.destroyed;
  }
}
