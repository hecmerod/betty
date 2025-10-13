import { Observable } from 'rxjs';
import { Readable } from 'stream';

export class VideoStream {
  constructor(
    public readonly stream: Readable,
    public readonly startedAt: Date = new Date(),
    public readonly format = 'mjpeg',
    public readonly metadata?: VideoStreamMetadata
  ) {
    if (!stream) {
      throw new Error('Video stream cannot be null or undefined');
    }

    if (!this.isValidFormat(format)) {
      throw new Error(`Invalid video format: ${format}`);
    }
  }

  isActive(): boolean {
    return !this.stream.destroyed && this.stream.readable;
  }

  getMimeType(): string {
    switch (this.format.toLowerCase()) {
      case 'mjpeg':
        return 'multipart/x-mixed-replace; boundary=frame';
      case 'webm':
        return 'video/webm';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  getActiveDuration(): number {
    return Date.now() - this.startedAt.getTime();
  }

  toJSON(): {
    startedAt: string;
    format: string;
    mimeType: string;
    isActive: boolean;
    activeDuration: number;
    metadata?: VideoStreamMetadata;
  } {
    return {
      startedAt: this.startedAt.toISOString(),
      format: this.format,
      mimeType: this.getMimeType(),
      isActive: this.isActive(),
      activeDuration: this.getActiveDuration(),
      metadata: this.metadata,
    };
  }

  asObservable(): Observable<Readable> {
    return new Observable((subscriber) => {
      subscriber.next(this.stream);

      this.stream.on('end', () => {
        subscriber.complete();
      });

      this.stream.on('error', (error) => {
        subscriber.error(error);
      });

      return () => {
        if (!this.stream.destroyed) {
          this.stream.destroy();
        }
      };
    });
  }

  private isValidFormat(format: string): boolean {
    const validFormats = ['mjpeg', 'webm', 'mp4', 'hls'];
    return validFormats.includes(format.toLowerCase());
  }
}

export interface VideoStreamMetadata {
  width?: number;
  height?: number;
  fps?: number;
  bitrate?: number;
  codec?: string;
}
