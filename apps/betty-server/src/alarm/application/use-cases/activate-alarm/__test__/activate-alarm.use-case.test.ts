import { ActivateAlarmUseCase } from '../activate-alarm.use-case';
import { AlarmRepository } from '../../../../domain/repositories/alarm.repository';

describe('ActivateAlarmUseCase', () => {
  let useCase: ActivateAlarmUseCase;
  let mockAlarmRepository: jest.Mocked<AlarmRepository>;

  beforeEach(() => {
    mockAlarmRepository = {
      activate: jest.fn(),
      deactivate: jest.fn(),
      get: jest.fn(),
      save: jest.fn(),
    } as jest.Mocked<AlarmRepository>;

    useCase = new ActivateAlarmUseCase(mockAlarmRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should activate the alarm successfully', async () => {
      mockAlarmRepository.activate.mockResolvedValue(undefined);

      const result = await useCase.execute();

      expect(mockAlarmRepository.activate).toHaveBeenCalledTimes(1);
      expect(result).toEqual({
        success: true,
        message: 'Alarm has been activated',
        status: 'active',
        timestamp: expect.any(String),
      });
    });

    it('should return success false when activation fails', async () => {
      const errorMessage = 'Alarm is already active';
      mockAlarmRepository.activate.mockRejectedValue(new Error(errorMessage));

      const result = await useCase.execute();

      expect(mockAlarmRepository.activate).toHaveBeenCalledTimes(1);
      expect(result).toEqual({
        success: false,
        message: errorMessage,
        timestamp: expect.any(String),
      });
    });

    it('should handle non-Error exceptions', async () => {
      mockAlarmRepository.activate.mockRejectedValue('Unknown error');

      const result = await useCase.execute();

      expect(result).toEqual({
        success: false,
        message: 'Failed to activate alarm',
        timestamp: expect.any(String),
      });
    });

    it('should return valid ISO timestamp', async () => {
      mockAlarmRepository.activate.mockResolvedValue(undefined);

      const result = await useCase.execute();

      expect(result.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
    });
  });
});
