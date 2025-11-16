import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnApplicationBootstrap,
} from '@nestjs/common';
import { Readable, PassThrough } from 'stream';
import { UsbCameraAdapter } from '../../infrastructure/adapters/usb-camera.adapter';
import { ImageObjectDetectionService } from '../../infrastructure/services/image-object-detection.service';
import { CameraType } from '../../domain/enums/camera-type.enum';
import { YoloClassId } from '../../domain/enums/yolo-class-id.enum';
import { TriggerAlarmUseCase } from '../../../alarm/application/use-cases/trigger-alarm/trigger-alarm.use-case';

const DETECTION_INTERVAL = 60;

@Injectable()
export class CameraDetectionProcess
  implements OnApplicationBootstrap, OnModuleDestroy
{
  private readonly logger = new Logger(CameraDetectionProcess.name);
  private sourceStream: Readable | null = null;
  private consumers: PassThrough[] = [];
  private lastDetectionFrame = 0;
  private frameCount = 0;

  constructor(
    private readonly usbCameraAdapter: UsbCameraAdapter,
    private readonly imageObjectDetection: ImageObjectDetectionService,
    private readonly triggerAlarmUseCase: TriggerAlarmUseCase
  ) {}

  onApplicationBootstrap() {
    this.startInternalCameraStream();
  }

  private startInternalCameraStream(): void {
    this.usbCameraAdapter.requestVideoStream(CameraType.INTERNAL).subscribe({
      next: (stream) => {
        this.sourceStream = stream;

        this.sourceStream.on('error', () => {
          setTimeout(() => this.restartStream(), 2000);
        });

        this.sourceStream.on('end', () => {
          this.consumers.forEach((consumer) => consumer.end());
        });

        this.onData();
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

  private onData(): void {
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

      if (frameStart === -1 || frameEnd === -1) return;

      const frame = buffer.subarray(frameStart, frameEnd + 2);
      buffer = buffer.subarray(frameEnd + 2);

      this.frameCount++;

      if (this.frameCount - this.lastDetectionFrame < DETECTION_INTERVAL)
        return;

      this.lastDetectionFrame = this.frameCount;

      const personsDetected = await this.imageObjectDetection.detectObjects(
        frame,
        YoloClassId.Person
      );

      if (personsDetected.length > 0) await this.triggerAlarmUseCase.execute();
    });
  }

  private async restartStream(): Promise<void> {
    this.stopInternalCameraStream();
    this.startInternalCameraStream();
  }

  private stopInternalCameraStream(): void {
    if (this.sourceStream) {
      this.sourceStream.destroy();
      this.sourceStream = null;
    }

    this.consumers.forEach((consumer) => {
      if (!consumer.destroyed) consumer.destroy();
    });
    this.consumers = [];
  }

  getStream(): Readable {
    if (!this.sourceStream || this.sourceStream.destroyed)
      return this.createOnDemandStream();

    const consumerStream = new PassThrough();
    this.consumers.push(consumerStream);

    consumerStream.on('close', () => {
      const index = this.consumers.indexOf(consumerStream);
      if (index > -1) this.consumers.splice(index, 1);
    });

    return consumerStream;
  }

  private createOnDemandStream(): Readable {
    const passThrough = new PassThrough();

    this.usbCameraAdapter.requestVideoStream(CameraType.INTERNAL).subscribe({
      next: (stream) => {
        this.sourceStream = stream;
        stream.pipe(passThrough);
      },
      error: (error) => {
        passThrough.destroy(error);
      },
    });

    return passThrough;
  }
}
