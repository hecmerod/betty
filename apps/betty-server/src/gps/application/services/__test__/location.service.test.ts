import { TriggerAlarmUseCase } from '../../../../alarm/application/use-cases/trigger-alarm/trigger-alarm.use-case';
import { SensorRepository } from '../../../../alarm/domain/repositories/sensor.repository';
import { Location } from '../../../domain/entities/location.entity';
import { LocationRepository } from '../../../domain/repositories/location.repository';
import { GetLastLocationUseCase } from '../../use-cases/get-last-location/get-last-location.use-case';
import { GetLocationUseCase } from '../../use-cases/get-location/get-location.use-case';
import { LocationService } from '../location.service';

describe('LocationService', () => {
  let service: LocationService;
  let mockGetLocationUseCase: jest.Mocked<Pick<GetLocationUseCase, 'execute'>>;
  let mockGetLastLocationUseCase: jest.Mocked<
    Pick<GetLastLocationUseCase, 'execute'>
  >;
  let mockLocationRepository: jest.Mocked<LocationRepository>;
  let mockSensorRepository: jest.Mocked<SensorRepository>;
  let mockTriggerAlarmUseCase: jest.Mocked<Pick<TriggerAlarmUseCase, 'execute'>>;
  const originalNodeEnv = process.env.NODE_ENV;

  const lastLocation = new Location(
    40.4168,
    -3.7038,
    new Date('2026-09-10T10:00:00.000Z')
  );
  const nearbyLocation = new Location(
    40.41681,
    -3.7038,
    new Date('2026-09-10T10:05:00.000Z')
  );
  const movedLocation = new Location(
    40.4172,
    -3.7038,
    new Date('2026-09-10T10:05:00.000Z')
  );

  beforeEach(() => {
    mockGetLocationUseCase = { execute: jest.fn() };
    mockGetLastLocationUseCase = { execute: jest.fn() };
    mockLocationRepository = {
      add: jest.fn(),
      get: jest.fn(),
    } as unknown as jest.Mocked<LocationRepository>;
    mockSensorRepository = {
      get: jest.fn(),
      getAll: jest.fn(),
      enableListening: jest.fn(),
      disableListening: jest.fn(),
      isListening: jest.fn(),
    } as unknown as jest.Mocked<SensorRepository>;
    mockTriggerAlarmUseCase = { execute: jest.fn() };

    service = new LocationService(
      mockGetLocationUseCase as unknown as GetLocationUseCase,
      mockGetLastLocationUseCase as unknown as GetLastLocationUseCase,
      mockLocationRepository,
      mockSensorRepository,
      mockTriggerAlarmUseCase as unknown as TriggerAlarmUseCase
    );

    mockSensorRepository.isListening.mockResolvedValue(true);
  });

  afterEach(() => {
    process.env.NODE_ENV = originalNodeEnv;
    service.onModuleDestroy();
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('checkLocation', () => {
    it('should store the first GPS reading without triggering the alarm', async () => {
      mockGetLocationUseCase.execute.mockResolvedValue({
        success: true,
        location: lastLocation,
      });
      mockGetLastLocationUseCase.execute.mockResolvedValue(null);

      await service.checkLocation();

      expect(mockLocationRepository.add).toHaveBeenCalledWith(lastLocation);
      expect(mockTriggerAlarmUseCase.execute).not.toHaveBeenCalled();
    });

    it('should ignore movement within 20 meters', async () => {
      mockGetLocationUseCase.execute.mockResolvedValue({
        success: true,
        location: nearbyLocation,
      });
      mockGetLastLocationUseCase.execute.mockResolvedValue(lastLocation);

      await service.checkLocation();

      expect(nearbyLocation.distanceTo(lastLocation)).toBeLessThanOrEqual(20);
      expect(mockLocationRepository.add).not.toHaveBeenCalled();
      expect(mockTriggerAlarmUseCase.execute).not.toHaveBeenCalled();
    });

    it('should add the new location and trigger the alarm when moved more than 20 meters', async () => {
      process.env.NODE_ENV = 'production';
      mockGetLocationUseCase.execute.mockResolvedValue({
        success: true,
        location: movedLocation,
      });
      mockGetLastLocationUseCase.execute.mockResolvedValue(lastLocation);

      await service.checkLocation();

      expect(movedLocation.distanceTo(lastLocation)).toBeGreaterThan(20);
      expect(mockLocationRepository.add).toHaveBeenCalledWith(movedLocation);
      expect(mockTriggerAlarmUseCase.execute).toHaveBeenCalledWith({
        eventType: 'location_moved',
        detectionType: 'location',
        metadata: { distanceMeters: expect.any(Number) },
      });
    });

    it('should not check GPS when the location sensor is not listening', async () => {
      mockSensorRepository.isListening.mockResolvedValue(false);

      await service.checkLocation();

      expect(mockGetLocationUseCase.execute).not.toHaveBeenCalled();
    });
  });
});
