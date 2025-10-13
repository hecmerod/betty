import { Readable } from 'stream';
import { VideoStream, VideoStreamMetadata } from '../video-stream.entity';

describe('VideoStream', () => {
  let mockStream: Readable;

  beforeEach(() => {
    mockStream = new Readable({
      read() {
        this.push('video data chunk');
      },
    });
  });

  afterEach(() => {
    if (!mockStream.destroyed) {
      mockStream.destroy();
    }
  });

  describe('constructor', () => {
    it('should create a video stream with valid data', () => {
      const startedAt = new Date();
      const metadata: VideoStreamMetadata = {
        width: 1920,
        height: 1080,
        fps: 30,
        bitrate: 5000000,
        codec: 'h264',
      };

      const videoStream = new VideoStream(
        mockStream,
        startedAt,
        'mjpeg',
        metadata
      );

      expect(videoStream.stream).toBe(mockStream);
      expect(videoStream.startedAt).toBe(startedAt);
      expect(videoStream.format).toBe('mjpeg');
      expect(videoStream.metadata).toBe(metadata);
    });

    it('should create a video stream with default values', () => {
      const videoStream = new VideoStream(mockStream);

      expect(videoStream.stream).toBe(mockStream);
      expect(videoStream.startedAt).toBeInstanceOf(Date);
      expect(videoStream.format).toBe('mjpeg');
      expect(videoStream.metadata).toBeUndefined();
    });

    it('should throw error for null stream', () => {
      const nullStream = null as unknown as Readable;
      expect(() => new VideoStream(nullStream)).toThrow(
        'Video stream cannot be null or undefined'
      );
    });

    it('should throw error for undefined stream', () => {
      const undefinedStream = undefined as unknown as Readable;
      expect(() => new VideoStream(undefinedStream)).toThrow(
        'Video stream cannot be null or undefined'
      );
    });

    it('should throw error for invalid format', () => {
      expect(() => new VideoStream(mockStream, new Date(), 'invalid')).toThrow(
        'Invalid video format: invalid'
      );
    });

    it('should accept valid formats', () => {
      const validFormats = ['mjpeg', 'webm', 'mp4', 'hls'];

      validFormats.forEach((format) => {
        const stream = new Readable({
          read() {
            // Empty implementation for test
          },
        });
        expect(() => new VideoStream(stream, new Date(), format)).not.toThrow();
        stream.destroy();
      });
    });
  });

  describe('isActive', () => {
    it('should return true when stream is active', () => {
      const videoStream = new VideoStream(mockStream);
      expect(videoStream.isActive()).toBe(true);
    });

    it('should return false when stream is destroyed', () => {
      const videoStream = new VideoStream(mockStream);
      mockStream.destroy();
      expect(videoStream.isActive()).toBe(false);
    });

    it('should return false when stream is not readable', () => {
      const nonReadableStream = new Readable({
        read() {
          // Empty implementation
        },
      });

      Object.defineProperty(nonReadableStream, 'readable', {
        value: false,
        writable: false,
      });

      const videoStream = new VideoStream(nonReadableStream);
      expect(videoStream.isActive()).toBe(false);
    });
  });

  describe('getMimeType', () => {
    it('should return correct MIME type for mjpeg', () => {
      const videoStream = new VideoStream(mockStream, new Date(), 'mjpeg');
      expect(videoStream.getMimeType()).toBe(
        'multipart/x-mixed-replace; boundary=frame'
      );
    });

    it('should return correct MIME type for webm', () => {
      const videoStream = new VideoStream(mockStream, new Date(), 'webm');
      expect(videoStream.getMimeType()).toBe('video/webm');
    });

    it('should return correct MIME type for mp4', () => {
      const videoStream = new VideoStream(mockStream, new Date(), 'mp4');
      expect(videoStream.getMimeType()).toBe('video/mp4');
    });

    it('should return default MIME type for unknown format', () => {
      const videoStream = new VideoStream(mockStream, new Date(), 'hls');
      expect(videoStream.getMimeType()).toBe('application/octet-stream');
    });

    it('should handle case insensitive formats', () => {
      const videoStreamUpperCase = new VideoStream(
        mockStream,
        new Date(),
        'MJPEG'
      );
      expect(videoStreamUpperCase.getMimeType()).toBe(
        'multipart/x-mixed-replace; boundary=frame'
      );
    });
  });

  describe('getActiveDuration', () => {
    it('should return correct active duration', (done) => {
      const startedAt = new Date(Date.now() - 5000);
      const videoStream = new VideoStream(mockStream, startedAt);

      setTimeout(() => {
        const duration = videoStream.getActiveDuration();
        expect(duration).toBeGreaterThanOrEqual(5000);
        expect(duration).toBeLessThan(6000);
        done();
      }, 100);
    });

    it('should return 0 or small value for just created stream', () => {
      const videoStream = new VideoStream(mockStream);
      const duration = videoStream.getActiveDuration();
      expect(duration).toBeGreaterThanOrEqual(0);
      expect(duration).toBeLessThan(1000);
    });
  });

  describe('toJSON', () => {
    it('should serialize video stream to JSON without stream data', () => {
      const startedAt = new Date('2024-01-01T12:00:00.000Z');
      const metadata: VideoStreamMetadata = {
        width: 1920,
        height: 1080,
        fps: 30,
      };
      const videoStream = new VideoStream(
        mockStream,
        startedAt,
        'webm',
        metadata
      );

      const json = videoStream.toJSON();

      expect(json).toEqual({
        startedAt: '2024-01-01T12:00:00.000Z',
        format: 'webm',
        mimeType: 'video/webm',
        isActive: true,
        activeDuration: expect.any(Number),
        metadata: metadata,
      });
      expect(json).not.toHaveProperty('stream');
    });

    it('should serialize video stream without metadata', () => {
      const startedAt = new Date('2024-01-01T12:00:00.000Z');
      const videoStream = new VideoStream(mockStream, startedAt, 'mjpeg');

      const json = videoStream.toJSON();

      expect(json).toEqual({
        startedAt: '2024-01-01T12:00:00.000Z',
        format: 'mjpeg',
        mimeType: 'multipart/x-mixed-replace; boundary=frame',
        isActive: true,
        activeDuration: expect.any(Number),
        metadata: undefined,
      });
    });
  });

  describe('asObservable', () => {
    it('should create observable that emits stream', (done) => {
      const videoStream = new VideoStream(mockStream);

      videoStream.asObservable().subscribe({
        next: (stream) => {
          expect(stream).toBe(mockStream);
          done();
        },
        error: done,
      });
    });

    it('should setup event listeners for stream end', () => {
      const videoStream = new VideoStream(mockStream);
      const onSpy = jest.spyOn(mockStream, 'on');

      const subscription = videoStream.asObservable().subscribe();

      expect(onSpy).toHaveBeenCalledWith('end', expect.any(Function));
      expect(onSpy).toHaveBeenCalledWith('error', expect.any(Function));

      subscription.unsubscribe();
    });

    it('should emit error when stream has error', (done) => {
      const videoStream = new VideoStream(mockStream);
      const testError = new Error('Stream error');

      videoStream.asObservable().subscribe({
        next: () => {
          setTimeout(() => {
            mockStream.emit('error', testError);
          }, 10);
        },
        error: (error) => {
          expect(error).toBe(testError);
          done();
        },
      });
    });

    it('should destroy stream on unsubscribe if not already destroyed', () => {
      const videoStream = new VideoStream(mockStream);
      const destroySpy = jest.spyOn(mockStream, 'destroy');

      const subscription = videoStream.asObservable().subscribe();
      subscription.unsubscribe();

      expect(destroySpy).toHaveBeenCalled();
    });

    it('should not destroy stream on unsubscribe if already destroyed', () => {
      const videoStream = new VideoStream(mockStream);
      mockStream.destroy();
      const destroySpy = jest.spyOn(mockStream, 'destroy');

      const subscription = videoStream.asObservable().subscribe();
      subscription.unsubscribe();

      expect(destroySpy).toHaveBeenCalledTimes(0);
    });
  });

  describe('private isValidFormat', () => {
    it('should validate format through constructor - valid formats', () => {
      const validFormats = ['mjpeg', 'webm', 'mp4', 'hls', 'MJPEG', 'WebM'];

      validFormats.forEach((format) => {
        const stream = new Readable({
          read() {
            // Empty implementation for test
          },
        });
        expect(() => new VideoStream(stream, new Date(), format)).not.toThrow();
        stream.destroy();
      });
    });

    it('should validate format through constructor - invalid formats', () => {
      const invalidFormats = ['avi', 'mov', 'flv', 'invalid', ''];

      invalidFormats.forEach((format) => {
        expect(() => new VideoStream(mockStream, new Date(), format)).toThrow(
          `Invalid video format: ${format}`
        );
      });
    });
  });
});
