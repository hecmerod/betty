import { AlarmController } from '../alarm.controller';
import { AlarmService } from '../alarm.service';

describe('AlarmController', () => {
  let controller: AlarmController;
  let mockAlarmService: jest.Mocked<AlarmService>;

  beforeEach(() => {
    mockAlarmService = {
      getStatus: jest.fn(),
      activate: jest.fn(),
      deactivate: jest.fn(),
      trigger: jest.fn(),
    } as unknown as jest.Mocked<AlarmService>;

    controller = new AlarmController(mockAlarmService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getAlarmStatus', () => {
    it('should return alarm status', () => {
      const mockStatusData = {
        active: true,
        status: 'active',
        timestamp: new Date().toISOString(),
      };
      mockAlarmService.getStatus.mockReturnValue(mockStatusData);

      const result = controller.getAlarmStatus();

      expect(mockAlarmService.getStatus).toHaveBeenCalled();
      expect(result).toBe(mockStatusData);
    });

    it('should call alarm service getStatus once', () => {
      controller.getAlarmStatus();

      expect(mockAlarmService.getStatus).toHaveBeenCalledTimes(1);
    });
  });

  describe('activateAlarm', () => {
    it('should activate alarm successfully', () => {
      const mockActivateData = {
        success: true,
        message: 'Alarm has been activated',
        status: 'active',
      };
      mockAlarmService.activate.mockReturnValue(mockActivateData);

      const result = controller.activateAlarm();

      expect(mockAlarmService.activate).toHaveBeenCalled();
      expect(result).toBe(mockActivateData);
    });

    it('should call alarm service activate once', () => {
      controller.activateAlarm();

      expect(mockAlarmService.activate).toHaveBeenCalledTimes(1);
    });
  });

  describe('deactivateAlarm', () => {
    it('should deactivate alarm successfully', () => {
      const mockDeactivateData = {
        success: true,
        message: 'Alarm has been deactivated',
        status: 'inactive',
      };
      mockAlarmService.deactivate.mockReturnValue(mockDeactivateData);

      const result = controller.deactivateAlarm();

      expect(mockAlarmService.deactivate).toHaveBeenCalled();
      expect(result).toBe(mockDeactivateData);
    });

    it('should call alarm service deactivate once', () => {
      controller.deactivateAlarm();

      expect(mockAlarmService.deactivate).toHaveBeenCalledTimes(1);
    });
  });

  describe('triggerAlarm', () => {
    it('should trigger alarm with provided data', () => {
      const mockTriggerData = { event_type: 'person', timestamp: '2023-01-01' };
      mockAlarmService.trigger.mockResolvedValue(undefined);

      const result = controller.triggerAlarm(mockTriggerData);

      expect(mockAlarmService.trigger).toHaveBeenCalledWith(mockTriggerData);
      expect(result).toBeDefined();
    });

    it('should call alarm service trigger once', () => {
      const mockTriggerData = { event_type: 'person' };
      controller.triggerAlarm(mockTriggerData);

      expect(mockAlarmService.trigger).toHaveBeenCalledTimes(1);
    });
  });
});
