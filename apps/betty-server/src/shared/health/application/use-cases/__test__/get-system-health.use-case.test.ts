import { GetSystemHealthUseCase } from '../get-system-health.use-case';

describe('GetSystemHealthUseCase', () => {
  let useCase: GetSystemHealthUseCase;

  beforeEach(() => {
    useCase = new GetSystemHealthUseCase();
  });

  describe('execute', () => {
    it('should return health status with correct structure', async () => {
      const result = await useCase.execute();

      expect(result).toHaveProperty('status', 'ok');
      expect(result).toHaveProperty('timestamp');
      expect(result).toHaveProperty('uptime');
      expect(result).toHaveProperty('memory');
      expect(result.memory).toHaveProperty('used');
      expect(result.memory).toHaveProperty('total');
      expect(result.memory).toHaveProperty('rss');
    });

    it('should return valid timestamp in ISO format', async () => {
      const result = await useCase.execute();

      expect(result.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
      expect(new Date(result.timestamp).getTime()).toBeGreaterThan(0);
    });

    it('should return positive uptime', async () => {
      const result = await useCase.execute();

      expect(result.uptime).toBeGreaterThan(0);
      expect(typeof result.uptime).toBe('number');
    });

    it('should return memory usage as positive numbers in MB', async () => {
      const result = await useCase.execute();

      expect(result.memory.used).toBeGreaterThan(0);
      expect(result.memory.total).toBeGreaterThan(0);
      expect(result.memory.rss).toBeGreaterThan(0);
      expect(Number.isInteger(result.memory.used)).toBe(true);
      expect(Number.isInteger(result.memory.total)).toBe(true);
      expect(Number.isInteger(result.memory.rss)).toBe(true);
    });

    it('should return consistent data structure on multiple calls', async () => {
      const result1 = await useCase.execute();
      const result2 = await useCase.execute();

      expect(Object.keys(result1)).toEqual(Object.keys(result2));
      expect(Object.keys(result1.memory)).toEqual(Object.keys(result2.memory));
    });
  });
});
