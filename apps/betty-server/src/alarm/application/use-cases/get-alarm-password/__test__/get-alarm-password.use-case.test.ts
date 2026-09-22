import { Alarm } from '../../../../domain/entities/alarm.entity';
import { AlarmRepository } from '../../../../domain/repositories/alarm.repository';
import { GetAlarmPasswordUseCase } from '../get-alarm-password.use-case';

describe('GetAlarmPasswordUseCase', () => {
  let useCase: GetAlarmPasswordUseCase;
  let mockAlarmRepository: jest.Mocked<AlarmRepository>;

  beforeEach(() => {
    mockAlarmRepository = {
      activate: jest.fn(),
      deactivate: jest.fn(),
      get: jest.fn(),
      setPassword: jest.fn(),
    } as jest.Mocked<AlarmRepository>;

    useCase = new GetAlarmPasswordUseCase(mockAlarmRepository);
  });

  it('should return the alarm password', async () => {
    mockAlarmRepository.get.mockResolvedValue(
      new Alarm(false, new Date(), '5678')
    );

    const result = await useCase.execute();

    expect(mockAlarmRepository.get).toHaveBeenCalledTimes(1);
    expect(result).toEqual({ password: '5678' });
  });
});
