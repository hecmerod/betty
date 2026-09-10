import { Location } from '../../../domain/entities/location.entity';
import { IGpsPort } from '../../../domain/ports/gps.port';
import { UsbGpsRepository } from '../usb-gps.repository';

describe('UsbGpsRepository', () => {
  let repository: UsbGpsRepository;
  let gpsPort: jest.Mocked<IGpsPort>;

  beforeEach(() => {
    gpsPort = {
      readLocation: jest.fn(),
    };

    repository = new UsbGpsRepository(gpsPort);
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('getCurrentLocation', () => {
    it('should map a GPS reading to a Location entity', async () => {
      const timestamp = new Date('2026-09-10T09:40:43.000Z');
      gpsPort.readLocation.mockResolvedValue({
        latitude: 40.4168,
        longitude: -3.7038,
        altitude: 650,
        timestamp,
      });

      const location = await repository.getCurrentLocation();

      expect(location).toBeInstanceOf(Location);
      expect(location.latitude).toBe(40.4168);
      expect(location.longitude).toBe(-3.7038);
      expect(location.altitude).toBe(650);
      expect(location.timestamp).toBe(timestamp);
    });

    it('should map a reading without altitude', async () => {
      gpsPort.readLocation.mockResolvedValue({
        latitude: 41.3851,
        longitude: 2.1734,
        timestamp: new Date(),
      });

      const location = await repository.getCurrentLocation();

      expect(location.altitude).toBeUndefined();
    });

    it('should propagate adapter errors', async () => {
      gpsPort.readLocation.mockRejectedValue(new Error('No GPS fix available'));

      await expect(repository.getCurrentLocation()).rejects.toThrow(
        'No GPS fix available'
      );
    });
  });
});
