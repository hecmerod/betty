import { CameraController } from '../camera.controller';
import { CameraService } from '../camera.service';
import { Response } from 'express';
import { of, throwError } from 'rxjs';
import { InternalServerErrorException } from '@nestjs/common';

describe('CameraController', () => {
  let controller: CameraController;
  let mockCameraService: jest.Mocked<CameraService>;
  let mockResponse: jest.Mocked<Response>;

  beforeEach(() => {
    mockCameraService = {
      capturePhoto: jest.fn(),
      getVideoStream: jest.fn(),
      checkCameraHealth: jest.fn(),
    } as unknown as jest.Mocked<CameraService>;

    mockResponse = {
      set: jest.fn(),
      end: jest.fn(),
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      headersSent: false,
      pipe: jest.fn(),
      on: jest.fn(),
    } as unknown as jest.Mocked<Response>;

    controller = new CameraController(mockCameraService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('capturePhoto', () => {
    it('should capture photo successfully', async () => {
      const mockPhotoBuffer = Buffer.from('fake-image-data');
      mockCameraService.capturePhoto.mockReturnValue(of(mockPhotoBuffer));

      await controller.capturePhoto(mockResponse);

      expect(mockCameraService.capturePhoto).toHaveBeenCalled();
      expect(mockResponse.set).toHaveBeenCalledWith({
        'Content-Type': 'image/jpeg',
        'Content-Length': mockPhotoBuffer.length.toString(),
        'Cache-Control': 'no-cache',
      });
      expect(mockResponse.end).toHaveBeenCalledWith(mockPhotoBuffer);
    });

    it('should handle camera service error', async () => {
      const errorMessage = 'Camera not available';
      mockCameraService.capturePhoto.mockReturnValue(
        throwError(() => new Error(errorMessage))
      );

      await controller.capturePhoto(mockResponse);

      expect(mockCameraService.capturePhoto).toHaveBeenCalled();
      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({
        error: 'Failed to capture photo',
        message: 'Camera service unavailable',
      });
    });

    it('should throw InternalServerErrorException on unexpected error', async () => {
      mockCameraService.capturePhoto.mockImplementation(() => {
        throw new Error('Unexpected error');
      });

      await expect(controller.capturePhoto(mockResponse)).rejects.toThrow(
        InternalServerErrorException
      );
    });

    it('should call camera service capturePhoto once', async () => {
      const mockPhotoBuffer = Buffer.from('fake-image-data');
      mockCameraService.capturePhoto.mockReturnValue(of(mockPhotoBuffer));

      await controller.capturePhoto(mockResponse);

      expect(mockCameraService.capturePhoto).toHaveBeenCalledTimes(1);
    });
  });

  describe('getVideoStream', () => {
    it('should get video stream successfully', async () => {
      const mockStream = {
        pipe: jest.fn(),
      } as unknown as NodeJS.ReadableStream;
      mockCameraService.getVideoStream.mockReturnValue(of(mockStream));

      await controller.getVideoStream(mockResponse);

      expect(mockCameraService.getVideoStream).toHaveBeenCalled();
      expect(mockResponse.set).toHaveBeenCalledWith({
        'Content-Type': 'multipart/x-mixed-replace; boundary=frame',
        'Cache-Control': 'no-cache',
        Connection: 'keep-alive',
        Pragma: 'no-cache',
      });
      expect(mockStream.pipe).toHaveBeenCalledWith(mockResponse);
    });

    it('should handle video stream error', async () => {
      const errorMessage = 'Stream not available';
      mockCameraService.getVideoStream.mockReturnValue(
        throwError(() => new Error(errorMessage))
      );

      await controller.getVideoStream(mockResponse);

      expect(mockCameraService.getVideoStream).toHaveBeenCalled();
      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({
        error: 'Failed to start video stream',
        message: 'Camera service unavailable',
      });
    });

    it('should call camera service getVideoStream once', async () => {
      const mockStream = {
        pipe: jest.fn(),
      } as unknown as NodeJS.ReadableStream;
      mockCameraService.getVideoStream.mockReturnValue(of(mockStream));

      await controller.getVideoStream(mockResponse);

      expect(mockCameraService.getVideoStream).toHaveBeenCalledTimes(1);
    });
  });
});
