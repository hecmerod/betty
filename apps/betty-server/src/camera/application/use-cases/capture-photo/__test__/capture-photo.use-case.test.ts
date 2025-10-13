import { CapturePhotoUseCase } from '../capture-photo.use-case';
import { CameraRepository } from '../../../../domain/repositories/camera.repository';
import { Photo } from '../../../../domain/entities/photo.entity';
import { of, throwError } from 'rxjs';

describe('CapturePhotoUseCase', () => {
  let useCase: CapturePhotoUseCase;
  let mockCameraRepository: jest.Mocked<CameraRepository>;

  beforeEach(() => {
    mockCameraRepository = {
      capturePhoto: jest.fn(),
      startVideoStream: jest.fn(),
      isAvailable: jest.fn(),
    };

    useCase = new CapturePhotoUseCase(mockCameraRepository);
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should capture photo successfully', (done) => {
      const photoData = Buffer.from('test image data');
      const photo = new Photo(photoData, new Date(), 'jpeg');

      mockCameraRepository.capturePhoto.mockReturnValue(of(photo));

      useCase.execute().subscribe({
        next: (result) => {
          expect(result).toBe(photo);
          expect(result.data).toBe(photoData);
          expect(mockCameraRepository.capturePhoto).toHaveBeenCalledTimes(1);
          done();
        },
      });
    });

    it('should handle repository errors', (done) => {
      const error = new Error('Camera not available');
      mockCameraRepository.capturePhoto.mockReturnValue(
        throwError(() => error)
      );

      useCase.execute().subscribe({
        error: (err) => {
          expect(err).toBe(error);
          expect(mockCameraRepository.capturePhoto).toHaveBeenCalledTimes(1);
          done();
        },
      });
    });

    it('should delegate to repository', () => {
      const photo = new Photo(Buffer.from('test'), new Date(), 'jpeg');
      mockCameraRepository.capturePhoto.mockReturnValue(of(photo));

      useCase.execute().subscribe();

      expect(mockCameraRepository.capturePhoto).toHaveBeenCalledWith();
    });
  });
});
