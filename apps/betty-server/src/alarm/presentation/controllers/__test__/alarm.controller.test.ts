import { AlarmController } from '../alarm.controller';
import { ActivateAlarmUseCase } from '../../../application/use-cases/activate-alarm/activate-alarm.use-case';
import { DeactivateAlarmUseCase } from '../../../application/use-cases/deactivate-alarm/deactivate-alarm.use-case';
import {
  TriggerAlarmUseCase,
  AlarmTriggerDataInput,
} from '../../../application/use-cases/trigger-alarm/trigger-alarm.use-case';
import { GetAlarmPasswordUseCase } from '../../../application/use-cases/get-alarm-password/get-alarm-password.use-case';
import { GetAlarmStatusUseCase } from '../../../application/use-cases/get-alarm-status/get-alarm-status.use-case';
import { SetAlarmPasswordUseCase } from '../../../application/use-cases/set-alarm-password/set-alarm-password.use-case';

describe('AlarmController', () => {
  let controller: AlarmController;
  let mockActivateAlarmUseCase: jest.Mocked<ActivateAlarmUseCase>;
  let mockDeactivateAlarmUseCase: jest.Mocked<DeactivateAlarmUseCase>;
  let mockTriggerAlarmUseCase: jest.Mocked<TriggerAlarmUseCase>;
  let mockGetAlarmStatusUseCase: jest.Mocked<GetAlarmStatusUseCase>;
  let mockGetAlarmPasswordUseCase: jest.Mocked<GetAlarmPasswordUseCase>;
  let mockSetAlarmPasswordUseCase: jest.Mocked<SetAlarmPasswordUseCase>;

  beforeEach(() => {
    mockActivateAlarmUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<ActivateAlarmUseCase>;

    mockDeactivateAlarmUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<DeactivateAlarmUseCase>;

    mockTriggerAlarmUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<TriggerAlarmUseCase>;

    mockGetAlarmStatusUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<GetAlarmStatusUseCase>;

    mockGetAlarmPasswordUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<GetAlarmPasswordUseCase>;

    mockSetAlarmPasswordUseCase = {
      execute: jest.fn(),
    } as unknown as jest.Mocked<SetAlarmPasswordUseCase>;

    controller = new AlarmController(
      mockActivateAlarmUseCase,
      mockDeactivateAlarmUseCase,
      mockTriggerAlarmUseCase,
      mockGetAlarmStatusUseCase,
      mockGetAlarmPasswordUseCase,
      mockSetAlarmPasswordUseCase
    );
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getAlarmStatus', () => {
    it('should return alarm status', async () => {
      const expectedStatus = {
        active: false,
        status: 'inactive',
        timestamp: '2024-01-01T00:00:00.000Z',
        activeDuration: 0,
      };

      mockGetAlarmStatusUseCase.execute.mockResolvedValue(expectedStatus);

      const result = await controller.getAlarmStatus();

      expect(mockGetAlarmStatusUseCase.execute).toHaveBeenCalledTimes(1);
      expect(result).toEqual(expectedStatus);
    });

    it('should return alarm status with timestamps', async () => {
      const expectedStatus = {
        active: true,
        status: 'active',
        timestamp: '2024-01-01T00:00:00.000Z',
        lastActivatedAt: '2024-01-01T00:00:00.000Z',
        lastDeactivatedAt: undefined,
        lastTriggeredAt: undefined,
        activeDuration: 1000,
      };

      mockGetAlarmStatusUseCase.execute.mockResolvedValue(expectedStatus);

      const result = await controller.getAlarmStatus();

      expect(result).toEqual(expectedStatus);
    });
  });

  describe('getPassword', () => {
    it('should return the alarm password', async () => {
      mockGetAlarmPasswordUseCase.execute.mockResolvedValue({
        password: '1234',
      });

      const result = await controller.getPassword();

      expect(mockGetAlarmPasswordUseCase.execute).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ password: '1234' });
    });
  });

  describe('setPassword', () => {
    it('should update the alarm password', async () => {
      const expectedResponse = {
        success: true,
        message: 'Alarm password has been updated',
        timestamp: '2024-01-01T00:00:00.000Z',
      };

      mockSetAlarmPasswordUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.setPassword({ password: '5678' });

      expect(mockSetAlarmPasswordUseCase.execute).toHaveBeenCalledWith('5678');
      expect(result).toEqual(expectedResponse);
    });
  });

  describe('activateAlarm', () => {
    it('should activate the alarm successfully', async () => {
      const expectedResponse = {
        success: true,
        message: 'Alarm has been activated',
        status: 'active',
        timestamp: '2024-01-01T00:00:00.000Z',
      };

      mockActivateAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.activateAlarm();

      expect(mockActivateAlarmUseCase.execute).toHaveBeenCalledTimes(1);
      expect(result).toEqual(expectedResponse);
    });

    it('should return error when activation fails', async () => {
      const expectedResponse = {
        success: false,
        message: 'Alarm is already active',
        timestamp: '2024-01-01T00:00:00.000Z',
      };

      mockActivateAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.activateAlarm();

      expect(result).toEqual(expectedResponse);
      expect(result.success).toBe(false);
    });
  });

  describe('deactivateAlarm', () => {
    it('should deactivate the alarm successfully', async () => {
      const expectedResponse = {
        success: true,
        message: 'Alarm has been deactivated',
        status: 'inactive',
        timestamp: '2024-01-01T00:00:00.000Z',
      };

      mockDeactivateAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.deactivateAlarm();

      expect(mockDeactivateAlarmUseCase.execute).toHaveBeenCalledTimes(1);
      expect(result).toEqual(expectedResponse);
    });

    it('should return error when deactivation fails', async () => {
      const expectedResponse = {
        success: false,
        message: 'Alarm is already inactive',
        timestamp: '2024-01-01T00:00:00.000Z',
      };

      mockDeactivateAlarmUseCase.execute.mockResolvedValue(expectedResponse);

      const result = await controller.deactivateAlarm();

      expect(result).toEqual(expectedResponse);
      expect(result.success).toBe(false);
    });
  });

  describe('triggerAlarm', () => {
    it('should trigger alarm without body', async () => {
      mockTriggerAlarmUseCase.execute.mockResolvedValue(true);

      const result = await controller.triggerAlarm(undefined);

      expect(mockTriggerAlarmUseCase.execute).toHaveBeenCalledWith(undefined);
      expect(result).toBe(true);
    });

    it('should trigger alarm with trigger data', async () => {
      const triggerData: AlarmTriggerDataInput = {
        eventType: 'motion_detected',
        detectionType: 'person',
        confidence: 0.95,
        metadata: { cameraId: 'cam-01' },
      };

      mockTriggerAlarmUseCase.execute.mockResolvedValue(true);

      const result = await controller.triggerAlarm(triggerData);

      expect(mockTriggerAlarmUseCase.execute).toHaveBeenCalledWith(triggerData);
      expect(result).toBe(true);
    });

    it('should return false when the trigger fails', async () => {
      mockTriggerAlarmUseCase.execute.mockResolvedValue(false);

      const result = await controller.triggerAlarm(undefined);

      expect(result).toBe(false);
    });
  });
});
