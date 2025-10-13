import { CameraController } from '../camera.controller';
import { CapturePhotoUseCase } from '../../../application/use-cases/capture-photo/capture-photo.use-case';
import { GetVideoStreamUseCase } from '../../../application/use-cases/get-video-stream/get-video-stream.use-case';
import { CheckCameraAvailabilityUseCase } from '../../../application/use-cases/check-camera-availability/check-camera-availability.use-case';
import { Photo } from '../../../domain/entities/photo.entity';
import { VideoStream } from '../../../domain/entities/video-stream.entity';
import { Response } from 'express';
import { of, throwError } from 'rxjs';
import { InternalServerErrorException } from '@nestjs/common';
import { Readable } from 'stream';

describe('CameraController', () => {
  let controller: CameraController;
  let mockCapturePhotoUseCase: jest.Mocked<CapturePhotoUseCase>;
  let mockGetVideoStreamUseCase: jest.Mocked<GetVideoStreamUseCase>;
  let mockCheckCameraAvailabilityUseCase: jest.Mocked<CheckCameraAvailabilityUseCase>;
  let mockResponse: jest.Mocked<Response>;

  beforeEach(() => {
    mockCapturePhotoUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<CapturePhotoUseCase>;

    mockGetVideoStreamUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<GetVideoStreamUseCase>;

    mockCheckCameraAvailabilityUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<CheckCameraAvailabilityUseCase>;

    mockResponse = {
      set: jest.fn(),
      end: jest.fn(),
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      headersSent: false,
      on: jest.fn(),
      pipe: jest.fn(),
    } as unknown as jest.Mocked<Response>;

    controller = new CameraController(
      mockCapturePhotoUseCase,
      mockGetVideoStreamUseCase,
      mockCheckCameraAvailabilityUseCase
    );
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('capturePhoto', () => {
    it('should capture photo successfully', async () => {
      const mockPhotoBuffer = Buffer.from('fake-image-data');
      const photo = new Photo(mockPhotoBuffer, new Date(), 'jpeg');
      mockCapturePhotoUseCase.execute.mockReturnValue(of(photo));

      await controller.capturePhoto(mockResponse);

      expect(mockCapturePhotoUseCase.execute).toHaveBeenCalled();
      expect(mockResponse.set).toHaveBeenCalledWith({
        'Content-Type': 'image/jpeg',
        'Content-Length': photo.getSize().toString(),
        'Cache-Control': 'no-cache',
      });
      expect(mockResponse.end).toHaveBeenCalledWith(photo.data);
    });

    it('should handle capture photo error', async () => {
      const error = new Error('Camera not available');
      mockCapturePhotoUseCase.execute.mockReturnValue(throwError(() => error));

      await controller.capturePhoto(mockResponse);

      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({
        error: 'Failed to capture photo',
        message: 'Camera service unavailable',
      });
    });

    it('should handle unexpected error', async () => {
      mockCapturePhotoUseCase.execute.mockImplementation(() => {
        throw new Error('Unexpected error');
      });

      await expect(controller.capturePhoto(mockResponse)).rejects.toThrow(
        InternalServerErrorException
      );
    });
  });

  describe('getVideoStream', () => {
    it('should get video stream successfully', async () => {
      const mockStream = new Readable();
      mockStream.pipe = jest.fn();
      const videoStream = new VideoStream(mockStream, new Date(), 'mjpeg');
      mockGetVideoStreamUseCase.execute.mockReturnValue(of(videoStream));

      await controller.getVideoStream(mockResponse);

      expect(mockGetVideoStreamUseCase.execute).toHaveBeenCalled();
      expect(mockResponse.set).toHaveBeenCalledWith({
        'Content-Type': 'multipart/x-mixed-replace; boundary=frame',
        'Cache-Control': 'no-cache',
        Connection: 'keep-alive',
        Pragma: 'no-cache',
      });
      expect(mockStream.pipe).toHaveBeenCalledWith(mockResponse);
    });

    it('should handle video stream error', async () => {
      const error = new Error('Stream not available');
      mockGetVideoStreamUseCase.execute.mockReturnValue(
        throwError(() => error)
      );

      await controller.getVideoStream(mockResponse);

      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({
        error: 'Failed to start video stream',
        message: 'Camera service unavailable',
      });
    });

    it('should handle unexpected error in video stream', async () => {
      mockGetVideoStreamUseCase.execute.mockImplementation(() => {
        throw new Error('Unexpected error');
      });

      await expect(controller.getVideoStream(mockResponse)).rejects.toThrow(
        InternalServerErrorException
      );
    });
  });

  describe('checkAvailability', () => {
    it('should return healthy status when camera is available', async () => {
      mockCheckCameraAvailabilityUseCase.execute.mockReturnValue(of(true));

      await controller.checkAvailability(mockResponse);

      expect(mockCheckCameraAvailabilityUseCase.execute).toHaveBeenCalled();
      expect(mockResponse.status).toHaveBeenCalledWith(200);
      expect(mockResponse.json).toHaveBeenCalledWith({
        status: 'healthy',
        camera: 'connected',
        timestamp: expect.any(String),
      });
    });

    it('should return unavailable status when camera is not available', async () => {
      mockCheckCameraAvailabilityUseCase.execute.mockReturnValue(of(false));

      await controller.checkAvailability(mockResponse);

      expect(mockResponse.status).toHaveBeenCalledWith(503);
      expect(mockResponse.json).toHaveBeenCalledWith({
        status: 'unavailable',
        camera: 'disconnected',
        timestamp: expect.any(String),
      });
    });

    it('should handle availability check error', async () => {
      const error = new Error('Check failed');
      mockCheckCameraAvailabilityUseCase.execute.mockReturnValue(
        throwError(() => error)
      );

      await controller.checkAvailability(mockResponse);

      expect(mockResponse.status).toHaveBeenCalledWith(503);
      expect(mockResponse.json).toHaveBeenCalledWith({
        status: 'error',
        camera: 'unknown',
        timestamp: expect.any(String),
        error: 'Check failed',
      });
    });

    it('should handle unexpected error in availability check', async () => {
      mockCheckCameraAvailabilityUseCase.execute.mockImplementation(() => {
        throw new Error('Unexpected error');
      });

      await expect(controller.checkAvailability(mockResponse)).rejects.toThrow(
        InternalServerErrorException
      );
    });
  });
});
