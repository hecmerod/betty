import { of, throwError } from 'rxjs';
import { Readable } from 'stream';
import { HttpCameraRepository } from '../http-camera.repository';
import { HttpCameraAdapter } from '../../adapters/http-camera.adapter';
import { Photo } from '../../../domain/entities/photo.entity';
import { VideoStream } from '../../../domain/entities/video-stream.entity';

describe('HttpCameraRepository', () => {
  let repository: HttpCameraRepository;
  let httpCameraAdapter: jest.Mocked<HttpCameraAdapter>;

  beforeEach(() => {
    httpCameraAdapter = {
      requestPhoto: jest.fn(),
      requestVideoStream: jest.fn(),
      checkAvailability: jest.fn(),
    } as unknown as jest.Mocked<HttpCameraAdapter>;

    repository = new HttpCameraRepository(httpCameraAdapter);
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('capturePhoto', () => {
    it('should capture photo and return Photo entity', (done) => {
      const mockBuffer = Buffer.from('mock image data');
      httpCameraAdapter.requestPhoto.mockReturnValue(of(mockBuffer));

      repository.capturePhoto().subscribe({
        next: (photo) => {
          expect(photo).toBeInstanceOf(Photo);
          expect(photo.data).toEqual(mockBuffer);
          expect(photo.format).toBe('jpeg');
          expect(photo.capturedAt).toBeInstanceOf(Date);
          done();
        },
        error: done,
      });

      expect(httpCameraAdapter.requestPhoto).toHaveBeenCalled();
    });

    it('should propagate error when adapter fails', (done) => {
      const error = new Error('Camera not available');
      httpCameraAdapter.requestPhoto.mockReturnValue(throwError(() => error));

      repository.capturePhoto().subscribe({
        next: () => done(new Error('Should not emit value')),
        error: (err) => {
          expect(err).toBe(error);
          done();
        },
      });
    });
  });

  describe('startVideoStream', () => {
    it('should start video stream and return VideoStream entity', (done) => {
      const mockStream = new Readable({
        read() {
          this.push('mock stream data');
          this.push(null);
        },
      });
      httpCameraAdapter.requestVideoStream.mockReturnValue(of(mockStream));

      repository.startVideoStream().subscribe({
        next: (videoStream) => {
          expect(videoStream).toBeInstanceOf(VideoStream);
          expect(videoStream.stream).toEqual(mockStream);
          expect(videoStream.format).toBe('mjpeg');
          expect(videoStream.startedAt).toBeInstanceOf(Date);
          done();
        },
        error: done,
      });

      expect(httpCameraAdapter.requestVideoStream).toHaveBeenCalled();
    });

    it('should propagate error when adapter fails', (done) => {
      const error = new Error('Stream not available');
      httpCameraAdapter.requestVideoStream.mockReturnValue(
        throwError(() => error)
      );

      repository.startVideoStream().subscribe({
        next: () => done(new Error('Should not emit value')),
        error: (err) => {
          expect(err).toBe(error);
          done();
        },
      });
    });
  });

  describe('isAvailable', () => {
    it('should return true when camera is available', (done) => {
      httpCameraAdapter.checkAvailability.mockReturnValue(of(true));

      repository.isAvailable().subscribe({
        next: (isAvailable) => {
          expect(isAvailable).toBe(true);
          done();
        },
        error: done,
      });

      expect(httpCameraAdapter.checkAvailability).toHaveBeenCalled();
    });

    it('should return false when camera is not available', (done) => {
      httpCameraAdapter.checkAvailability.mockReturnValue(of(false));

      repository.isAvailable().subscribe({
        next: (isAvailable) => {
          expect(isAvailable).toBe(false);
          done();
        },
        error: done,
      });
    });

    it('should propagate error when adapter fails', (done) => {
      const error = new Error('Health check failed');
      httpCameraAdapter.checkAvailability.mockReturnValue(
        throwError(() => error)
      );

      repository.isAvailable().subscribe({
        next: () => done(new Error('Should not emit value')),
        error: (err) => {
          expect(err).toBe(error);
          done();
        },
      });
    });
  });
});
