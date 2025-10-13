import { of, throwError } from 'rxjs';
import { CheckCameraAvailabilityUseCase } from '../check-camera-availability.use-case';
import { CameraRepository } from '../../../../domain/repositories/camera.repository';

describe('CheckCameraAvailabilityUseCase', () => {
  let useCase: CheckCameraAvailabilityUseCase;
  let mockCameraRepository: jest.Mocked<CameraRepository>;

  beforeEach(() => {
    mockCameraRepository = {
      isAvailable: jest.fn(),
      capturePhoto: jest.fn(),
      startVideoStream: jest.fn(),
    } as unknown as jest.Mocked<CameraRepository>;

    useCase = new CheckCameraAvailabilityUseCase(mockCameraRepository);
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should return true when camera is available', (done) => {
      mockCameraRepository.isAvailable.mockReturnValue(of(true));

      useCase.execute().subscribe({
        next: (isAvailable) => {
          expect(isAvailable).toBe(true);
          expect(mockCameraRepository.isAvailable).toHaveBeenCalled();
          done();
        },
        error: done,
      });
    });

    it('should return false when camera is not available', (done) => {
      mockCameraRepository.isAvailable.mockReturnValue(of(false));

      useCase.execute().subscribe({
        next: (isAvailable) => {
          expect(isAvailable).toBe(false);
          expect(mockCameraRepository.isAvailable).toHaveBeenCalled();
          done();
        },
        error: done,
      });
    });

    it('should propagate error when repository throws', (done) => {
      const error = new Error('Repository error');
      mockCameraRepository.isAvailable.mockReturnValue(throwError(() => error));

      useCase.execute().subscribe({
        next: () => done(new Error('Should not emit value')),
        error: (err) => {
          expect(err).toBe(error);
          expect(mockCameraRepository.isAvailable).toHaveBeenCalled();
          done();
        },
      });
    });

    it('should delegate to repository without modification', () => {
      const mockObservable = of(true);
      mockCameraRepository.isAvailable.mockReturnValue(mockObservable);

      const result = useCase.execute();

      expect(result).toBe(mockObservable);
      expect(mockCameraRepository.isAvailable).toHaveBeenCalledTimes(1);
    });
  });
});
