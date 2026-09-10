import { GetLocationsUseCase } from '../get-locations.use-case';
import { LocationRepository } from '../../../../domain/repositories/location.repository';
import { Location } from '../../../../domain/entities/location.entity';

describe('GetLocationsUseCase', () => {
  let useCase: GetLocationsUseCase;
  let mockLocationRepository: jest.Mocked<LocationRepository>;

  const from = new Date('2026-09-10T00:00:00.000Z');
  const to = new Date('2026-09-10T23:59:59.000Z');

  beforeEach(() => {
    mockLocationRepository = {
      add: jest.fn(),
      get: jest.fn(),
    } as unknown as jest.Mocked<LocationRepository>;

    useCase = new GetLocationsUseCase(mockLocationRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should return paginated locations from the repository', async () => {
      const locations = [
        new Location(40.4168, -3.7038, from, 650),
        new Location(40.417, -3.704, new Date('2026-09-10T01:00:00.000Z')),
      ];
      mockLocationRepository.get.mockResolvedValue(locations);

      const result = await useCase.execute(from, to, 2);

      expect(mockLocationRepository.get).toHaveBeenCalledWith(from, to, 2);
      expect(result).toBe(locations);
    });

    it('should default to page 1', async () => {
      mockLocationRepository.get.mockResolvedValue([]);

      await useCase.execute(from, to);

      expect(mockLocationRepository.get).toHaveBeenCalledWith(from, to, 1);
    });
  });
});
