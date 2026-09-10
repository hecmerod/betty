import { HttpException, HttpStatus } from '@nestjs/common';
import { GetLocationsUseCase } from '../../../application/use-cases/get-locations/get-locations.use-case';
import { Location } from '../../../domain/entities/location.entity';
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

      const result = await controller.getLocations(from, to, '2');

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

      await controller.getLocations(from, to);

      expect(mockGetLocationsUseCase.execute).toHaveBeenCalledWith(
        new Date(from),
        new Date(to),
        1
      );
    });

    it('should reject an invalid from datetime', async () => {
      await expect(controller.getLocations('not-a-date', to)).rejects.toEqual(
        new HttpException('Invalid from datetime', HttpStatus.BAD_REQUEST)
      );
      expect(mockGetLocationsUseCase.execute).not.toHaveBeenCalled();
    });

    it('should reject an invalid to datetime', async () => {
      await expect(controller.getLocations(from, 'nope')).rejects.toEqual(
        new HttpException('Invalid to datetime', HttpStatus.BAD_REQUEST)
      );
    });

    it('should reject an invalid page', async () => {
      await expect(controller.getLocations(from, to, '0')).rejects.toEqual(
        new HttpException('Invalid page', HttpStatus.BAD_REQUEST)
      );
    });
  });
});
