import { GetAlarmStatusUseCase } from '../get-alarm-status.use-case';
import { AlarmRepository } from '../../../../domain/repositories/alarm.repository';
import { Alarm } from '../../../../domain/entities/alarm.entity';

describe('GetAlarmStatusUseCase', () => {
  let useCase: GetAlarmStatusUseCase;
  let mockAlarmRepository: jest.Mocked<AlarmRepository>;

  beforeEach(() => {
    mockAlarmRepository = {
      activate: jest.fn(),
      deactivate: jest.fn(),
      get: jest.fn(),
      save: jest.fn(),
    } as jest.Mocked<AlarmRepository>;

    useCase = new GetAlarmStatusUseCase(mockAlarmRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should return status of inactive alarm', async () => {
      const inactiveAlarm = new Alarm(false);
      mockAlarmRepository.get.mockResolvedValue(inactiveAlarm);

      const result = await useCase.execute();

      expect(mockAlarmRepository.get).toHaveBeenCalledTimes(1);
      expect(result).toEqual({
        active: false,
        status: 'inactive',
        timestamp: expect.any(String),
        lastActivatedAt: undefined,
        lastDeactivatedAt: undefined,
        lastTriggeredAt: undefined,
        activeDuration: 0,
      });
    });

    it('should return status of active alarm', async () => {
      const activeAlarm = new Alarm(true);
      mockAlarmRepository.get.mockResolvedValue(activeAlarm);

      const result = await useCase.execute();

      expect(mockAlarmRepository.get).toHaveBeenCalledTimes(1);
      expect(result).toEqual({
        active: true,
        status: 'active',
        timestamp: expect.any(String),
        lastActivatedAt: undefined,
        lastDeactivatedAt: undefined,
        lastTriggeredAt: undefined,
        activeDuration: 0,
      });
    });

    it('should return status with activation timestamp', async () => {
      const alarm = new Alarm(false);
      alarm.activate();
      mockAlarmRepository.get.mockResolvedValue(alarm);

      const result = await useCase.execute();

      expect(result).toEqual({
        active: true,
        status: 'active',
        timestamp: expect.any(String),
        lastActivatedAt: expect.any(String),
        lastDeactivatedAt: undefined,
        lastTriggeredAt: undefined,
        activeDuration: expect.any(Number),
      });
    });

    it('should return status with deactivation timestamp', async () => {
      const alarm = new Alarm(false);
      alarm.activate();
      alarm.deactivate();
      mockAlarmRepository.get.mockResolvedValue(alarm);

      const result = await useCase.execute();

      expect(result).toEqual({
        active: false,
        status: 'inactive',
        timestamp: expect.any(String),
        lastActivatedAt: expect.any(String),
        lastDeactivatedAt: expect.any(String),
        lastTriggeredAt: undefined,
        activeDuration: expect.any(Number),
      });
    });

    it('should return valid ISO timestamp', async () => {
      const alarm = new Alarm(false);
      mockAlarmRepository.get.mockResolvedValue(alarm);

      const result = await useCase.execute();

      expect(result.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
    });

    it('should include active duration', async () => {
      const alarm = new Alarm(false);
      alarm.activate();

      // Wait a bit to get some duration
      await new Promise((resolve) => setTimeout(resolve, 10));

      mockAlarmRepository.get.mockResolvedValue(alarm);

      const result = await useCase.execute();

      expect(result.activeDuration).toBeGreaterThan(0);
    });
  });
});
