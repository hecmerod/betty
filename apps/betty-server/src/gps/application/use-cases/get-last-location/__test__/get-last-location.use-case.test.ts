import { GetLastLocationUseCase } from '../get-last-location.use-case';
import { LocationRepository } from '../../../../domain/repositories/location.repository';
import { Location } from '../../../../domain/entities/location.entity';

describe('GetLastLocationUseCase', () => {
  let useCase: GetLastLocationUseCase;
  let mockLocationRepository: jest.Mocked<LocationRepository>;

  beforeEach(() => {
    mockLocationRepository = {
      add: jest.fn(),
      get: jest.fn(),
    } as unknown as jest.Mocked<LocationRepository>;

    useCase = new GetLastLocationUseCase(mockLocationRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should return the last stored location using take 1', async () => {
      const lastLocation = new Location(40.4168, -3.7038, new Date(), 650);
      mockLocationRepository.get.mockResolvedValue([lastLocation]);

      const result = await useCase.execute();

      expect(mockLocationRepository.get).toHaveBeenCalledWith(
        undefined,
        undefined,
        1,
        1
      );
      expect(result).toBe(lastLocation);
    });

    it('should return null when there are no stored locations', async () => {
      mockLocationRepository.get.mockResolvedValue([]);

      const result = await useCase.execute();

      expect(result).toBeNull();
    });
  });
});
