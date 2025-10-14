import { MockGpsRepository } from '../mock-gps.repository';
import { Location } from '../../../domain/entities/location.entity';

describe('MockGpsRepository', () => {
  let repository: MockGpsRepository;

  beforeEach(() => {
    repository = new MockGpsRepository();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('getCurrentLocation', () => {
    it('should return a Location instance', async () => {
      const location = await repository.getCurrentLocation();

      expect(location).toBeInstanceOf(Location);
    });

    it('should return location with coordinates near Madrid', async () => {
      const location = await repository.getCurrentLocation();

      // Coordenadas base de Madrid: 40.4168, -3.7038
      expect(location.latitude).toBeGreaterThan(40.4);
      expect(location.latitude).toBeLessThan(40.5);
      expect(location.longitude).toBeGreaterThan(-3.8);
      expect(location.longitude).toBeLessThan(-3.6);
    });

    it('should return location with altitude', async () => {
      const location = await repository.getCurrentLocation();

      expect(location.altitude).toBeDefined();
      // Altitud base de Madrid: 650m con variación de ±10m
      expect(location.altitude).toBeGreaterThan(640);
      expect(location.altitude).toBeLessThan(660);
    });

    it('should return location with current timestamp', async () => {
      const beforeCall = Date.now();
      const location = await repository.getCurrentLocation();
      const afterCall = Date.now();

      expect(location.timestamp.getTime()).toBeGreaterThanOrEqual(beforeCall);
      expect(location.timestamp.getTime()).toBeLessThanOrEqual(afterCall);
    });

    it('should return slightly different coordinates on multiple calls', async () => {
      const location1 = await repository.getCurrentLocation();
      const location2 = await repository.getCurrentLocation();

      // Deberían ser diferentes debido a la variación aleatoria
      const areDifferent =
        location1.latitude !== location2.latitude ||
        location1.longitude !== location2.longitude;

      expect(areDifferent).toBe(true);
    });

    it('should return locations within small distance from each other', async () => {
      const location1 = await repository.getCurrentLocation();
      const location2 = await repository.getCurrentLocation();

      const distance = location1.distanceTo(location2);

      // La variación es de ±0.0005 grados (~55m), por lo que la distancia máxima
      // entre dos puntos debería ser menor a 200m
      expect(distance).toBeLessThan(200);
    });

    it('should return valid coordinates every time', async () => {
      // Ejecutar múltiples veces para verificar consistencia
      for (let i = 0; i < 10; i++) {
        const location = await repository.getCurrentLocation();

        expect(location.latitude).toBeGreaterThanOrEqual(-90);
        expect(location.latitude).toBeLessThanOrEqual(90);
        expect(location.longitude).toBeGreaterThanOrEqual(-180);
        expect(location.longitude).toBeLessThanOrEqual(180);
      }
    });
  });
});
