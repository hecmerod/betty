import { HealthController } from '../health.controller';
import { GetSystemHealthUseCase } from '../../../application/use-cases/get-system-health.use-case';

describe('HealthController', () => {
  let controller: HealthController;
  let mockGetSystemHealthUseCase: jest.Mocked<GetSystemHealthUseCase>;

  beforeEach(() => {
    mockGetSystemHealthUseCase = {
      execute: jest.fn(),
    } as jest.Mocked<GetSystemHealthUseCase>;

    controller = new HealthController(mockGetSystemHealthUseCase);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getHealth', () => {
    it('should return health status', async () => {
      const mockHealthData = {
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: 12345,
        memory: {
          used: 1024,
          total: 2048,
          rss: 512,
        },
      };
      mockGetSystemHealthUseCase.execute.mockResolvedValue(mockHealthData);

      const result = await controller.getHealth();

      expect(mockGetSystemHealthUseCase.execute).toHaveBeenCalled();
      expect(result).toBe(mockHealthData);
    });

    it('should call use case once', async () => {
      const mockHealthData = {
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: 12345,
        memory: {
          used: 1024,
          total: 2048,
          rss: 512,
        },
      };
      mockGetSystemHealthUseCase.execute.mockResolvedValue(mockHealthData);

      await controller.getHealth();

      expect(mockGetSystemHealthUseCase.execute).toHaveBeenCalledTimes(1);
    });
  });
});
