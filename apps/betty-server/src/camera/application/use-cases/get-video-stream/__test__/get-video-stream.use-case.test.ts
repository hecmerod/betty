import { of, throwError } from 'rxjs';
import { Readable } from 'stream';
import { GetVideoStreamUseCase } from '../get-video-stream.use-case';
import { CameraRepository } from '../../../../domain/repositories/camera.repository';
import { VideoStream } from '../../../../domain/entities/video-stream.entity';

describe('GetVideoStreamUseCase', () => {
  let useCase: GetVideoStreamUseCase;
  let mockCameraRepository: jest.Mocked<CameraRepository>;

  beforeEach(() => {
    mockCameraRepository = {
      startVideoStream: jest.fn(),
      capturePhoto: jest.fn(),
      isAvailable: jest.fn(),
    } as unknown as jest.Mocked<CameraRepository>;

    useCase = new GetVideoStreamUseCase(mockCameraRepository);
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should return video stream from repository', (done) => {
      const mockStream = new Readable({
        read() {
          this.push('video data');
          this.push(null);
        },
      });
      const mockVideoStream = new VideoStream(mockStream, new Date(), 'mjpeg');

      mockCameraRepository.startVideoStream.mockReturnValue(
        of(mockVideoStream)
      );

      useCase.execute().subscribe({
        next: (videoStream) => {
          expect(videoStream).toBe(mockVideoStream);
          expect(videoStream).toBeInstanceOf(VideoStream);
          expect(mockCameraRepository.startVideoStream).toHaveBeenCalled();
          done();
        },
        error: done,
      });
    });

    it('should propagate error when repository throws', (done) => {
      const error = new Error('Stream unavailable');
      mockCameraRepository.startVideoStream.mockReturnValue(
        throwError(() => error)
      );

      useCase.execute().subscribe({
        next: () => done(new Error('Should not emit value')),
        error: (err) => {
          expect(err).toBe(error);
          expect(mockCameraRepository.startVideoStream).toHaveBeenCalled();
          done();
        },
      });
    });

    it('should delegate to repository without modification', () => {
      const mockStream = new Readable({
        read() {
          this.push(null);
        },
      });
      const mockVideoStream = new VideoStream(mockStream);
      const mockObservable = of(mockVideoStream);

      mockCameraRepository.startVideoStream.mockReturnValue(mockObservable);

      const result = useCase.execute();

      expect(result).toBe(mockObservable);
      expect(mockCameraRepository.startVideoStream).toHaveBeenCalledTimes(1);
    });

    it('should handle multiple video stream emissions', (done) => {
      const mockStream1 = new Readable({
        read() {
          this.push('stream1');
          this.push(null);
        },
      });
      const mockStream2 = new Readable({
        read() {
          this.push('stream2');
          this.push(null);
        },
      });

      const videoStream1 = new VideoStream(mockStream1, new Date(), 'mjpeg');
      const videoStream2 = new VideoStream(mockStream2, new Date(), 'mjpeg');

      let emissionCount = 0;
      const expectedStreams = [videoStream1, videoStream2];

      mockCameraRepository.startVideoStream.mockReturnValue(
        of(videoStream1, videoStream2)
      );

      useCase.execute().subscribe({
        next: (videoStream) => {
          expect(videoStream).toBe(expectedStreams[emissionCount]);
          emissionCount++;

          if (emissionCount === 2) {
            done();
          }
        },
        error: done,
      });
    });
  });
});
