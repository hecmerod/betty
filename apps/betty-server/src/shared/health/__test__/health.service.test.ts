import { HealthService } from '../health.service';

describe('HealthService', () => {
  let service: HealthService;

  beforeEach(() => {
    service = new HealthService();
  });

  describe('getHealth', () => {
    it('should return health status with correct structure', () => {
      const result = service.getHealth();

      expect(result).toHaveProperty('status', 'ok');
      expect(result).toHaveProperty('timestamp');
      expect(result).toHaveProperty('uptime');
      expect(result).toHaveProperty('memory');
      expect(result.memory).toHaveProperty('used');
      expect(result.memory).toHaveProperty('total');
      expect(result.memory).toHaveProperty('rss');
    });

    it('should return valid timestamp in ISO format', () => {
      const result = service.getHealth();

      expect(result.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
      expect(new Date(result.timestamp).getTime()).toBeGreaterThan(0);
    });

    it('should return positive uptime', () => {
      const result = service.getHealth();

      expect(result.uptime).toBeGreaterThan(0);
      expect(typeof result.uptime).toBe('number');
    });

    it('should return memory usage as positive numbers in MB', () => {
      const result = service.getHealth();

      expect(result.memory.used).toBeGreaterThan(0);
      expect(result.memory.total).toBeGreaterThan(0);
      expect(result.memory.rss).toBeGreaterThan(0);
      expect(Number.isInteger(result.memory.used)).toBe(true);
      expect(Number.isInteger(result.memory.total)).toBe(true);
      expect(Number.isInteger(result.memory.rss)).toBe(true);
    });

    it('should return consistent data structure on multiple calls', () => {
      const result1 = service.getHealth();
      const result2 = service.getHealth();

      expect(Object.keys(result1)).toEqual(Object.keys(result2));
      expect(Object.keys(result1.memory)).toEqual(Object.keys(result2.memory));
    });
  });
});
