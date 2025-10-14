import { Location } from '../location.entity';

describe('Location', () => {
  describe('constructor', () => {
    it('should create a location with valid coordinates', () => {
      const latitude = 40.4168;
      const longitude = -3.7038;
      const altitude = 650;

      const location = new Location(latitude, longitude, new Date(), altitude);

      expect(location.latitude).toBe(latitude);
      expect(location.longitude).toBe(longitude);
      expect(location.altitude).toBe(altitude);
      expect(location.timestamp).toBeInstanceOf(Date);
    });

    it('should create a location without altitude', () => {
      const latitude = 40.4168;
      const longitude = -3.7038;

      const location = new Location(latitude, longitude);

      expect(location.latitude).toBe(latitude);
      expect(location.longitude).toBe(longitude);
      expect(location.altitude).toBeUndefined();
    });

    it('should throw error for invalid latitude (too high)', () => {
      expect(() => {
        new Location(91, 0);
      }).toThrow('Latitude must be between -90 and 90 degrees');
    });

    it('should throw error for invalid latitude (too low)', () => {
      expect(() => {
        new Location(-91, 0);
      }).toThrow('Latitude must be between -90 and 90 degrees');
    });

    it('should throw error for invalid longitude (too high)', () => {
      expect(() => {
        new Location(0, 181);
      }).toThrow('Longitude must be between -180 and 180 degrees');
    });

    it('should throw error for invalid longitude (too low)', () => {
      expect(() => {
        new Location(0, -181);
      }).toThrow('Longitude must be between -180 and 180 degrees');
    });

    it('should accept boundary latitude values', () => {
      expect(() => new Location(90, 0)).not.toThrow();
      expect(() => new Location(-90, 0)).not.toThrow();
    });

    it('should accept boundary longitude values', () => {
      expect(() => new Location(0, 180)).not.toThrow();
      expect(() => new Location(0, -180)).not.toThrow();
    });
  });

  describe('distanceTo', () => {
    it('should calculate distance between two locations correctly', () => {
      // Madrid
      const location1 = new Location(40.4168, -3.7038);
      // Barcelona
      const location2 = new Location(41.3851, 2.1734);

      const distance = location1.distanceTo(location2);

      // La distancia entre Madrid y Barcelona es aproximadamente 504km
      expect(distance).toBeGreaterThan(500000); // 500km
      expect(distance).toBeLessThan(510000); // 510km
    });

    it('should return 0 for the same location', () => {
      const location1 = new Location(40.4168, -3.7038);
      const location2 = new Location(40.4168, -3.7038);

      const distance = location1.distanceTo(location2);

      expect(distance).toBeLessThan(1); // Debería ser casi 0
    });

    it('should calculate small distances correctly', () => {
      // Dos puntos muy cercanos (diferencia de ~0.001 grados ≈ 111 metros)
      const location1 = new Location(40.4168, -3.7038);
      const location2 = new Location(40.4178, -3.7038);

      const distance = location1.distanceTo(location2);

      expect(distance).toBeGreaterThan(100); // ~100 metros
      expect(distance).toBeLessThan(120); // ~120 metros
    });
  });

  describe('isWithinRadius', () => {
    it('should return true when location is within radius', () => {
      const location1 = new Location(40.4168, -3.7038);
      const location2 = new Location(40.4178, -3.7038); // ~111 metros

      const result = location1.isWithinRadius(location2, 150);

      expect(result).toBe(true);
    });

    it('should return false when location is outside radius', () => {
      const location1 = new Location(40.4168, -3.7038);
      const location2 = new Location(40.4178, -3.7038); // ~111 metros

      const result = location1.isWithinRadius(location2, 100);

      expect(result).toBe(false);
    });

    it('should return true when location is exactly at radius', () => {
      const location1 = new Location(0, 0);
      const location2 = new Location(0, 0);

      const result = location1.isWithinRadius(location2, 0);

      expect(result).toBe(true);
    });
  });

  describe('toJSON', () => {
    it('should serialize location to JSON with all fields', () => {
      const timestamp = new Date('2025-10-14T10:00:00Z');
      const location = new Location(40.4168, -3.7038, timestamp, 650);

      const json = location.toJSON();

      expect(json).toEqual({
        latitude: 40.4168,
        longitude: -3.7038,
        timestamp: '2025-10-14T10:00:00.000Z',
        altitude: 650,
      });
    });

    it('should serialize location to JSON without altitude', () => {
      const timestamp = new Date('2025-10-14T10:00:00Z');
      const location = new Location(40.4168, -3.7038, timestamp);

      const json = location.toJSON();

      expect(json).toEqual({
        latitude: 40.4168,
        longitude: -3.7038,
        timestamp: '2025-10-14T10:00:00.000Z',
        altitude: undefined,
      });
    });
  });

  describe('toString', () => {
    it('should return string representation of location', () => {
      const location = new Location(40.4168, -3.7038);

      const result = location.toString();

      expect(result).toBe('Location(40.4168, -3.7038)');
    });

    it('should return string representation with negative coordinates', () => {
      const location = new Location(-34.6037, -58.3816); // Buenos Aires

      const result = location.toString();

      expect(result).toBe('Location(-34.6037, -58.3816)');
    });
  });
});
