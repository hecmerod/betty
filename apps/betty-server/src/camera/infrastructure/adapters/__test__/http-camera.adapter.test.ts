import { HttpCameraAdapter } from '../http-camera.adapter';
import { HttpService } from '@nestjs/axios';
import { of, throwError } from 'rxjs';
import { AxiosResponse } from 'axios';
import { InternalServerErrorException } from '@nestjs/common';
import { Readable } from 'stream';

describe('HttpCameraAdapter', () => {
  let adapter: HttpCameraAdapter;
  let mockHttpService: jest.Mocked<HttpService>;
  const originalEnv = process.env.CAMERA_SERVICE_URL;

  beforeEach(() => {
    mockHttpService = {
      get: jest.fn(),
    } as unknown as jest.Mocked<HttpService>;
  });

  afterEach(() => {
    process.env.CAMERA_SERVICE_URL = originalEnv;
  });

  describe('constructor', () => {
    it('should use default URL when environment variable is not set', () => {
      delete process.env.CAMERA_SERVICE_URL;
      adapter = new HttpCameraAdapter(mockHttpService);
      expect(adapter).toBeDefined();
    });

    it('should use environment variable when set', () => {
      process.env.CAMERA_SERVICE_URL = 'http://custom-camera:9000/api';
      adapter = new HttpCameraAdapter(mockHttpService);
      expect(adapter).toBeDefined();
    });
  });

  describe('with custom environment URL', () => {
    beforeEach(() => {
      process.env.CAMERA_SERVICE_URL = 'http://custom-camera:9000/api';
      adapter = new HttpCameraAdapter(mockHttpService);
    });

    it('should use custom URL for photo requests', (done) => {
      const mockImageData = new ArrayBuffer(1024);
      const mockResponse: AxiosResponse<ArrayBuffer> = {
        data: mockImageData,
        status: 200,
        statusText: 'OK',
        headers: {},
        config: {},
      } as AxiosResponse<ArrayBuffer>;
      mockHttpService.get.mockReturnValue(of(mockResponse));

      adapter.requestPhoto().subscribe({
        next: () => {
          expect(mockHttpService.get).toHaveBeenCalledWith(
            'http://custom-camera:9000/api/photo',
            {
              responseType: 'arraybuffer',
              timeout: 15000,
            }
          );
          done();
        },
      });
    });
  });

  describe('with default configuration', () => {
    beforeEach(() => {
      process.env.CAMERA_SERVICE_URL = 'http://localhost:8001/camera';
      adapter = new HttpCameraAdapter(mockHttpService);
    });

    it('should be defined', () => {
      expect(adapter).toBeDefined();
    });

    describe('requestPhoto', () => {
      it('should request photo successfully', (done) => {
        const mockImageData = new ArrayBuffer(1024);
        const mockResponse: AxiosResponse<ArrayBuffer> = {
          data: mockImageData,
          status: 200,
          statusText: 'OK',
          headers: {},
          config: {},
        } as AxiosResponse<ArrayBuffer>;
        mockHttpService.get.mockReturnValue(of(mockResponse));

        adapter.requestPhoto().subscribe({
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

        adapter.requestPhoto().subscribe({
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

        adapter.requestPhoto().subscribe();

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

    describe('requestVideoStream', () => {
      it('should request video stream successfully', (done) => {
        const mockStream = new Readable();
        const mockResponse: AxiosResponse<Readable> = {
          data: mockStream,
          status: 200,
          statusText: 'OK',
          headers: {},
          config: {},
        } as AxiosResponse<Readable>;
        mockHttpService.get.mockReturnValue(of(mockResponse));

        adapter.requestVideoStream().subscribe({
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

        adapter.requestVideoStream().subscribe({
          error: (err) => {
            expect(err).toBeInstanceOf(InternalServerErrorException);
            expect(err.message).toBe(
              'Failed to start video stream from camera'
            );
            done();
          },
        });
      });

      it('should call http service with correct parameters for video stream', () => {
        const mockResponse: AxiosResponse<Readable> = {
          data: new Readable(),
          status: 200,
          statusText: 'OK',
          headers: {},
          config: {},
        } as AxiosResponse<Readable>;
        mockHttpService.get.mockReturnValue(of(mockResponse));

        adapter.requestVideoStream().subscribe();

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

    describe('checkAvailability', () => {
      it('should return true when camera service is available', (done) => {
        const mockResponse: AxiosResponse = {
          data: { status: 'ok' },
          status: 200,
          statusText: 'OK',
          headers: {},
          config: {},
        } as AxiosResponse;
        mockHttpService.get.mockReturnValue(of(mockResponse));

        adapter.checkAvailability().subscribe({
          next: (isAvailable) => {
            expect(isAvailable).toBe(true);
            expect(mockHttpService.get).toHaveBeenCalledWith(
              'http://localhost:8001/camera/health',
              {
                timeout: 5000,
              }
            );
            done();
          },
        });
      });

      it('should return false when camera service is not available', (done) => {
        const error = new Error('Service unavailable');
        mockHttpService.get.mockReturnValue(throwError(() => error));

        adapter.checkAvailability().subscribe({
          next: (isAvailable) => {
            expect(isAvailable).toBe(false);
            done();
          },
        });
      });
    });
  });
});
