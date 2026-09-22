import { Alarm } from '../../../domain/entities/alarm.entity';
import { AlarmRepository } from '../../../domain/repositories/alarm.repository';
import { IGpioPort } from '../../../../gpio/domain/ports/gpio.port';
import { AlarmService } from '../alarm.service';

describe('AlarmService', () => {
  let service: AlarmService;
  let mockAlarmRepository: jest.Mocked<AlarmRepository>;
  let mockGpioPort: jest.Mocked<IGpioPort>;

  beforeEach(() => {
    jest.useFakeTimers();

    mockAlarmRepository = {
      activate: jest.fn(),
      deactivate: jest.fn(),
      get: jest.fn(),
    } as jest.Mocked<AlarmRepository>;

    mockGpioPort = {
      setPin: jest.fn().mockResolvedValue(undefined),
      getPin: jest.fn(),
      watchPin: jest.fn(),
      unwatchPin: jest.fn(),
    };

    service = new AlarmService(mockAlarmRepository, mockGpioPort);
  });

  afterEach(async () => {
    await service.onModuleDestroy();
    jest.useRealTimers();
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should start the alarm sound on the alarm pin', async () => {
    mockAlarmRepository.get.mockResolvedValue(new Alarm(true));

    service.activate();
    await jest.runOnlyPendingTimersAsync();

    expect(mockGpioPort.setPin).toHaveBeenCalledWith(17, false);
  });

  it('should not start a second sound loop when already active', async () => {
    mockAlarmRepository.get.mockResolvedValue(new Alarm(true));

    service.activate();
    await Promise.resolve();

    expect(mockGpioPort.setPin).toHaveBeenCalledTimes(1);

    service.activate();
    await Promise.resolve();

    expect(mockGpioPort.setPin).toHaveBeenCalledTimes(1);
    expect(mockAlarmRepository.get).toHaveBeenCalledTimes(1);
  });

  it('should stop cycling when the alarm is deactivated', async () => {
    mockAlarmRepository.get.mockResolvedValue(new Alarm(true));

    service.activate();
    await jest.runOnlyPendingTimersAsync();

    mockAlarmRepository.get.mockResolvedValue(new Alarm(false));
    await jest.advanceTimersByTimeAsync(500);

    const pinCalls = mockGpioPort.setPin.mock.calls.length;

    await jest.advanceTimersByTimeAsync(1000);

    expect(mockGpioPort.setPin).toHaveBeenCalledTimes(pinCalls);
  });

  it('should turn the alarm pin off when the module is destroyed', async () => {
    mockAlarmRepository.get.mockResolvedValue(new Alarm(true));

    service.activate();
    await jest.runOnlyPendingTimersAsync();
    await service.onModuleDestroy();

    expect(mockGpioPort.setPin).toHaveBeenLastCalledWith(17, true);
  });
});
