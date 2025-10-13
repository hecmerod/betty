import { DeactivateAlarmUseCase } from '../deactivate-alarm.use-case';
import { AlarmRepository } from '../../../../domain/repositories/alarm.repository';

describe('DeactivateAlarmUseCase', () => {
  let useCase: DeactivateAlarmUseCase;
  let mockAlarmRepository: jest.Mocked<AlarmRepository>;

  beforeEach(() => {
    mockAlarmRepository = {
      activate: jest.fn(),
      deactivate: jest.fn(),
      get: jest.fn(),
      save: jest.fn(),
    } as jest.Mocked<AlarmRepository>;

    useCase = new DeactivateAlarmUseCase(mockAlarmRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should deactivate the alarm successfully', async () => {
      mockAlarmRepository.deactivate.mockResolvedValue(undefined);

      const result = await useCase.execute();

      expect(mockAlarmRepository.deactivate).toHaveBeenCalledTimes(1);
      expect(result).toEqual({
        success: true,
        message: 'Alarm has been deactivated',
        status: 'inactive',
        timestamp: expect.any(String),
      });
    });

    it('should return success false when deactivation fails', async () => {
      const errorMessage = 'Alarm is already inactive';
      mockAlarmRepository.deactivate.mockRejectedValue(new Error(errorMessage));

      const result = await useCase.execute();

      expect(mockAlarmRepository.deactivate).toHaveBeenCalledTimes(1);
      expect(result).toEqual({
        success: false,
        message: errorMessage,
        timestamp: expect.any(String),
      });
    });

    it('should handle non-Error exceptions', async () => {
      mockAlarmRepository.deactivate.mockRejectedValue('Unknown error');

      const result = await useCase.execute();

      expect(result).toEqual({
        success: false,
        message: 'Failed to deactivate alarm',
        timestamp: expect.any(String),
      });
    });

    it('should return valid ISO timestamp', async () => {
      mockAlarmRepository.deactivate.mockResolvedValue(undefined);

      const result = await useCase.execute();

      expect(result.timestamp).toMatch(
        /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/
      );
    });
  });
});
