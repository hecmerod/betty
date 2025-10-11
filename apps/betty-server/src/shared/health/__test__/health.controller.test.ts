import { HealthController } from '../health.controller';
import { HealthService } from '../health.service';

describe('HealthController', () => {
  let controller: HealthController;
  let mockHealthService: jest.Mocked<HealthService>;

  beforeEach(() => {
    mockHealthService = {
      getHealth: jest.fn(),
    } as jest.Mocked<HealthService>;

    controller = new HealthController(mockHealthService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getHealth', () => {
    it('should return health status', () => {
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
      mockHealthService.getHealth.mockReturnValue(mockHealthData);

      const result = controller.getHealth();

      expect(mockHealthService.getHealth).toHaveBeenCalled();
      expect(result).toBe(mockHealthData);
    });

    it('should call health service once', () => {
      controller.getHealth();

      expect(mockHealthService.getHealth).toHaveBeenCalledTimes(1);
    });
  });
});
