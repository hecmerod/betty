import { AlarmRepository } from '../../../../domain/repositories/alarm.repository';
import { SetAlarmPasswordUseCase } from '../set-alarm-password.use-case';

describe('SetAlarmPasswordUseCase', () => {
  let useCase: SetAlarmPasswordUseCase;
  let mockAlarmRepository: jest.Mocked<AlarmRepository>;

  beforeEach(() => {
    mockAlarmRepository = {
      activate: jest.fn(),
      deactivate: jest.fn(),
      get: jest.fn(),
      setPassword: jest.fn(),
    } as jest.Mocked<AlarmRepository>;

    useCase = new SetAlarmPasswordUseCase(mockAlarmRepository);
  });

  it('should update the alarm password', async () => {
    mockAlarmRepository.setPassword.mockResolvedValue(undefined);

    const result = await useCase.execute('5678');

    expect(mockAlarmRepository.setPassword).toHaveBeenCalledWith('5678');
    expect(result).toEqual({
      success: true,
      message: 'Alarm password has been updated',
      timestamp: expect.any(String),
    });
  });

  it('should return success false when the update fails', async () => {
    mockAlarmRepository.setPassword.mockRejectedValue(
      new Error('Alarm record not found')
    );

    const result = await useCase.execute('5678');

    expect(result).toEqual({
      success: false,
      message: 'Alarm record not found',
      timestamp: expect.any(String),
    });
  });
});
