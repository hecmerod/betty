import { CameraService } from '../camera.service';
import { HttpService } from '@nestjs/axios';
import { of, throwError } from 'rxjs';
import { AxiosResponse } from 'axios';
import { InternalServerErrorException } from '@nestjs/common';

describe('CameraService', () => {
  let service: CameraService;
  let mockHttpService: jest.Mocked<HttpService>;

  beforeEach(() => {
    mockHttpService = {
      get: jest.fn(),
    } as unknown as jest.Mocked<HttpService>;

    service = new CameraService(mockHttpService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('capturePhoto', () => {
    it('should capture photo successfully', (done) => {
      const mockImageData = new ArrayBuffer(1024);
      const mockResponse: AxiosResponse<ArrayBuffer> = {
        data: mockImageData,
        status: 200,
        statusText: 'OK',
        headers: {},
        config: {},
      } as AxiosResponse<ArrayBuffer>;
      mockHttpService.get.mockReturnValue(of(mockResponse));

      service.capturePhoto().subscribe({
        next: (buffer) => {
          expect(buffer).toBeInstanceOf(Buffer);
          expect(buffer.length).toBe(1024);
          expect(mockHttpService.get).toHaveBeenCalledWith(
            'http://localhost:8001/camera/photo',
            {
              responseType: 'arraybuffer',
              timeout: 15000,
            }
          );
          done();
        },
      });
    });

    it('should handle camera service error', (done) => {
      const error = new Error('Camera not available');
      mockHttpService.get.mockReturnValue(throwError(() => error));

      service.capturePhoto().subscribe({
        error: (err) => {
          expect(err).toBeInstanceOf(InternalServerErrorException);
          expect(err.message).toBe('Failed to capture photo from camera');
          done();
        },
      });
    });

    it('should call http service with correct parameters', () => {
      const mockResponse: AxiosResponse<ArrayBuffer> = {
        data: new ArrayBuffer(0),
        status: 200,
        statusText: 'OK',
        headers: {},
        config: {},
      } as AxiosResponse<ArrayBuffer>;
      mockHttpService.get.mockReturnValue(of(mockResponse));

      service.capturePhoto().subscribe();

      expect(mockHttpService.get).toHaveBeenCalledTimes(1);
      expect(mockHttpService.get).toHaveBeenCalledWith(
        'http://localhost:8001/camera/photo',
        {
          responseType: 'arraybuffer',
          timeout: 15000,
        }
      );
    });
  });

  describe('getVideoStream', () => {
    it('should get video stream successfully', (done) => {
      const mockStream = {} as NodeJS.ReadableStream;
      const mockResponse: AxiosResponse<NodeJS.ReadableStream> = {
        data: mockStream,
        status: 200,
        statusText: 'OK',
        headers: {},
        config: {},
      } as AxiosResponse<NodeJS.ReadableStream>;
      mockHttpService.get.mockReturnValue(of(mockResponse));

      service.getVideoStream().subscribe({
        next: (stream) => {
          expect(stream).toBe(mockStream);
          expect(mockHttpService.get).toHaveBeenCalledWith(
            'http://localhost:8001/camera/video',
            {
              responseType: 'stream',
              timeout: 0,
            }
          );
          done();
        },
      });
    });

    it('should handle video stream error', (done) => {
      const error = new Error('Stream not available');
      mockHttpService.get.mockReturnValue(throwError(() => error));

      service.getVideoStream().subscribe({
        error: (err) => {
          expect(err).toBeInstanceOf(InternalServerErrorException);
          expect(err.message).toBe('Failed to start video stream from camera');
          done();
        },
      });
    });

    it('should call http service with correct parameters for video stream', () => {
      const mockResponse: AxiosResponse<NodeJS.ReadableStream> = {
        data: {} as NodeJS.ReadableStream,
        status: 200,
        statusText: 'OK',
        headers: {},
        config: {},
      } as AxiosResponse<NodeJS.ReadableStream>;
      mockHttpService.get.mockReturnValue(of(mockResponse));

      service.getVideoStream().subscribe();

      expect(mockHttpService.get).toHaveBeenCalledTimes(1);
      expect(mockHttpService.get).toHaveBeenCalledWith(
        'http://localhost:8001/camera/video',
        {
          responseType: 'stream',
          timeout: 0,
        }
      );
    });
  });
});
