import { GetLocationsUseCase } from '../../../application/use-cases/get-locations/get-locations.use-case';
import { Location } from '../../../domain/entities/location.entity';
import { GetLocationsQueryDto } from '../../dto/location.dto';
import { LocationController } from '../location.controller';

describe('LocationController', () => {
  let controller: LocationController;
  let mockGetLocationsUseCase: jest.Mocked<GetLocationsUseCase>;

  const from = '2026-09-10T00:00:00.000Z';
  const to = '2026-09-10T23:59:59.000Z';
  const timestamp = new Date(from);

  beforeEach(() => {
    mockGetLocationsUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<GetLocationsUseCase>;

    controller = new LocationController(mockGetLocationsUseCase);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getLocations', () => {
    it('should return serialized locations for a valid range', async () => {
      const location = new Location(40.4168, -3.7038, timestamp, 650);
      mockGetLocationsUseCase.execute.mockResolvedValue([location]);

      const query: GetLocationsQueryDto = { from, to, page: 2 };
      const result = await controller.getLocations(query);

      expect(mockGetLocationsUseCase.execute).toHaveBeenCalledWith(
        new Date(from),
        new Date(to),
        2
      );
      expect(result).toEqual({
        locations: [
          {
            latitude: 40.4168,
            longitude: -3.7038,
            timestamp: from,
            altitude: 650,
          },
        ],
      });
    });

    it('should default page to 1 when omitted', async () => {
      mockGetLocationsUseCase.execute.mockResolvedValue([]);

      const query: GetLocationsQueryDto = { from, to };
      await controller.getLocations(query);

      expect(mockGetLocationsUseCase.execute).toHaveBeenCalledWith(
        new Date(from),
        new Date(to),
        1
      );
    });

    it('should request all locations when no datetime range is provided', async () => {
      mockGetLocationsUseCase.execute.mockResolvedValue([]);

      await controller.getLocations({});

      expect(mockGetLocationsUseCase.execute).toHaveBeenCalledWith(
        undefined,
        undefined,
        1
      );
    });
  });
});
