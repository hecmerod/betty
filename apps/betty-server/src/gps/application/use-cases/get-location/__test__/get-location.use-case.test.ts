import { GetLocationUseCase } from '../get-location.use-case';
import { GpsRepository } from '../../../../domain/repositories/gps.repository';
import { Location } from '../../../../domain/entities/location.entity';

describe('GetLocationUseCase', () => {
  let useCase: GetLocationUseCase;
  let mockGpsRepository: jest.Mocked<GpsRepository>;

  beforeEach(() => {
    mockGpsRepository = {
      getCurrentLocation: jest.fn(),
      isAvailable: jest.fn(),
    } as jest.Mocked<GpsRepository>;

    useCase = new GetLocationUseCase(mockGpsRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should return location successfully', async () => {
      const mockLocation = new Location(40.4168, -3.7038, new Date(), 650);
      mockGpsRepository.getCurrentLocation.mockResolvedValue(mockLocation);

      const result = await useCase.execute();

      expect(mockGpsRepository.getCurrentLocation).toHaveBeenCalledTimes(1);
      expect(result).toEqual({
        success: true,
        location: {
          latitude: 40.4168,
          longitude: -3.7038,
          timestamp: expect.any(String),
          altitude: 650,
        },
      });
    });

    it('should return location without altitude', async () => {
      const mockLocation = new Location(40.4168, -3.7038);
      mockGpsRepository.getCurrentLocation.mockResolvedValue(mockLocation);

      const result = await useCase.execute();

      expect(mockGpsRepository.getCurrentLocation).toHaveBeenCalledTimes(1);
      expect(result).toEqual({
        success: true,
        location: {
          latitude: 40.4168,
          longitude: -3.7038,
          timestamp: expect.any(String),
          altitude: undefined,
        },
      });
    });

    it('should return error when repository throws Error instance', async () => {
      const error = new Error('GPS hardware failure');
      mockGpsRepository.getCurrentLocation.mockRejectedValue(error);

      const result = await useCase.execute();

      expect(result).toEqual({
        success: false,
        error: 'GPS hardware failure',
      });
    });

    it('should return generic error when repository throws non-Error', async () => {
      mockGpsRepository.getCurrentLocation.mockRejectedValue('Unknown error');

      const result = await useCase.execute();

      expect(result).toEqual({
        success: false,
        error: 'Failed to get location',
      });
    });

    it('should format timestamp as ISO string', async () => {
      const timestamp = new Date('2025-10-14T10:30:00Z');
      const mockLocation = new Location(40.4168, -3.7038, timestamp);
      mockGpsRepository.getCurrentLocation.mockResolvedValue(mockLocation);

      const result = await useCase.execute();

      expect(result.location?.timestamp).toBe('2025-10-14T10:30:00.000Z');
    });

    it('should handle negative coordinates', async () => {
      // Buenos Aires coordinates
      const mockLocation = new Location(-34.6037, -58.3816);
      mockGpsRepository.getCurrentLocation.mockResolvedValue(mockLocation);

      const result = await useCase.execute();

      expect(result).toEqual({
        success: true,
        location: {
          latitude: -34.6037,
          longitude: -58.3816,
          timestamp: expect.any(String),
          altitude: undefined,
        },
      });
    });

    it('should handle boundary coordinates', async () => {
      const mockLocation = new Location(90, 180, new Date(), 0);
      mockGpsRepository.getCurrentLocation.mockResolvedValue(mockLocation);

      const result = await useCase.execute();

      expect(result).toEqual({
        success: true,
        location: {
          latitude: 90,
          longitude: 180,
          timestamp: expect.any(String),
          altitude: 0,
        },
      });
    });
  });
});
