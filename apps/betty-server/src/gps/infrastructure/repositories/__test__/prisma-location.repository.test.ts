import { Location } from '../../../domain/entities/location.entity';
import { PrismaService } from '../../../../shared/prisma/prisma.service';
import { PrismaLocationRepository } from '../prisma-location.repository';

describe('PrismaLocationRepository', () => {
  let repository: PrismaLocationRepository;
  let mockPrismaLocation: {
    create: jest.Mock;
    findMany: jest.Mock;
  };

  const recordedAt = new Date('2026-09-10T10:00:00.000Z');
  const prismaRecord = {
    id: 'location-id',
    latitude: 40.4168,
    longitude: -3.7038,
    altitude: 650,
    recordedAt,
    createdAt: new Date('2026-09-10T10:00:01.000Z'),
  };

  beforeEach(() => {
    mockPrismaLocation = {
      create: jest.fn(),
      findMany: jest.fn(),
    };

    const mockPrismaService = {
      location: mockPrismaLocation,
    } as unknown as jest.Mocked<PrismaService>;

    repository = new PrismaLocationRepository(mockPrismaService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('add', () => {
    it('should persist a location and return the domain entity', async () => {
      mockPrismaLocation.create.mockResolvedValue(prismaRecord);

      const location = new Location(40.4168, -3.7038, recordedAt, 650);
      const result = await repository.add(location);

      expect(mockPrismaLocation.create).toHaveBeenCalledWith({
        data: {
          id: expect.any(String),
          latitude: 40.4168,
          longitude: -3.7038,
          altitude: 650,
          recordedAt,
        },
      });
      expect(result).toBeInstanceOf(Location);
      expect(result.latitude).toBe(40.4168);
      expect(result.longitude).toBe(-3.7038);
      expect(result.altitude).toBe(650);
      expect(result.timestamp).toEqual(recordedAt);
    });

    it('should persist a location without altitude', async () => {
      mockPrismaLocation.create.mockResolvedValue({
        ...prismaRecord,
        altitude: null,
      });

      const location = new Location(40.4168, -3.7038, recordedAt);
      const result = await repository.add(location);

      expect(mockPrismaLocation.create).toHaveBeenCalledWith({
        data: {
          id: expect.any(String),
          latitude: 40.4168,
          longitude: -3.7038,
          altitude: undefined,
          recordedAt,
        },
      });
      expect(result.altitude).toBeUndefined();
    });
  });

  describe('get', () => {
    const from = new Date('2026-09-10T00:00:00.000Z');
    const to = new Date('2026-09-10T23:59:59.000Z');

    it('should return locations in the datetime range, paginated by 10', async () => {
      mockPrismaLocation.findMany.mockResolvedValue([prismaRecord]);

      const result = await repository.get(from, to);

      expect(mockPrismaLocation.findMany).toHaveBeenCalledWith({
        where: {
          recordedAt: {
            gte: from,
            lte: to,
          },
        },
        orderBy: { recordedAt: 'asc' },
        skip: 0,
        take: 10,
      });
      expect(result).toHaveLength(1);
      expect(result[0]).toBeInstanceOf(Location);
      expect(result[0].latitude).toBe(40.4168);
    });

    it('should apply page offset of 10 records per page', async () => {
      mockPrismaLocation.findMany.mockResolvedValue([]);

      await repository.get(from, to, 3);

      expect(mockPrismaLocation.findMany).toHaveBeenCalledWith({
        where: {
          recordedAt: {
            gte: from,
            lte: to,
          },
        },
        orderBy: { recordedAt: 'asc' },
        skip: 20,
        take: 10,
      });
    });

    it('should treat invalid pages as page 1', async () => {
      mockPrismaLocation.findMany.mockResolvedValue([]);

      await repository.get(from, to, 0);

      expect(mockPrismaLocation.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          skip: 0,
          take: 10,
        })
      );
    });

    it('should return the last location when take is 1 and no date range', async () => {
      mockPrismaLocation.findMany.mockResolvedValue([prismaRecord]);

      const result = await repository.get(undefined, undefined, 1, 1);

      expect(mockPrismaLocation.findMany).toHaveBeenCalledWith({
        where: undefined,
        orderBy: { recordedAt: 'desc' },
        skip: 0,
        take: 1,
      });
      expect(result).toHaveLength(1);
      expect(result[0].latitude).toBe(40.4168);
    });

    it('should return all locations when no datetime range is provided', async () => {
      mockPrismaLocation.findMany.mockResolvedValue([prismaRecord]);

      const result = await repository.get();

      expect(mockPrismaLocation.findMany).toHaveBeenCalledWith({
        where: undefined,
        orderBy: { recordedAt: 'desc' },
      });
      expect(result).toHaveLength(1);
    });
  });
});
