import { Alarm } from '../alarm.entity';

describe('Alarm', () => {
  describe('constructor', () => {
    it('should create alarm with default values', () => {
      const alarm = new Alarm();

      expect(alarm.isActive).toBe(false);
      expect(alarm.status).toBe('inactive');
      expect(alarm.createdAt).toBeInstanceOf(Date);
    });

    it('should create alarm with all parameters', () => {
      const createdAt = new Date('2024-01-01');
      const lastActivatedAt = new Date('2024-01-02');

      const alarm = new Alarm(true, createdAt, lastActivatedAt);

      expect(alarm.isActive).toBe(true);
      expect(alarm.status).toBe('active');
      expect(alarm.createdAt).toBe(createdAt);
      expect(alarm.lastActivatedAt).toBe(lastActivatedAt);
    });
  });

  describe('activate', () => {
    it('should activate inactive alarm', () => {
      const alarm = new Alarm();

      alarm.activate();

      expect(alarm.isActive).toBe(true);
      expect(alarm.status).toBe('active');
      expect(alarm.lastActivatedAt).toBeInstanceOf(Date);
    });

    it('should throw error when activating already active alarm', () => {
      const alarm = new Alarm(true);

      expect(() => alarm.activate()).toThrow('Alarm is already active');
    });

    it('should update lastActivatedAt timestamp', () => {
      const alarm = new Alarm();
      const beforeActivation = Date.now();

      alarm.activate();

      expect(alarm.lastActivatedAt?.getTime()).toBeGreaterThanOrEqual(
        beforeActivation
      );
    });
  });

  describe('deactivate', () => {
    it('should deactivate active alarm', () => {
      const alarm = new Alarm(true);

      alarm.deactivate();

      expect(alarm.isActive).toBe(false);
      expect(alarm.status).toBe('inactive');
      expect(alarm.lastDeactivatedAt).toBeInstanceOf(Date);
    });

    it('should throw error when deactivating already inactive alarm', () => {
      const alarm = new Alarm(false);

      expect(() => alarm.deactivate()).toThrow('Alarm is already inactive');
    });

    it('should update lastDeactivatedAt timestamp', () => {
      const alarm = new Alarm(true);
      const beforeDeactivation = Date.now();

      alarm.deactivate();

      expect(alarm.lastDeactivatedAt?.getTime()).toBeGreaterThanOrEqual(
        beforeDeactivation
      );
    });
  });

  describe('getActiveDuration', () => {
    it('should return 0 for inactive alarm', () => {
      const alarm = new Alarm(false);

      expect(alarm.getActiveDuration()).toBe(0);
    });

    it('should return 0 for active alarm without activation timestamp', () => {
      const alarm = new Alarm(true);

      expect(alarm.getActiveDuration()).toBe(0);
    });

    it('should calculate correct active duration', (done) => {
      const alarm = new Alarm(false);

      alarm.activate();

      setTimeout(() => {
        const duration = alarm.getActiveDuration();
        expect(duration).toBeGreaterThan(90);
        expect(duration).toBeLessThan(200);
        done();
      }, 100);
    });
  });

  describe('toJSON', () => {
    it('should serialize alarm correctly', () => {
      const createdAt = new Date('2024-01-01T10:00:00.000Z');
      const alarm = new Alarm(false, createdAt);

      alarm.activate();

      const json = alarm.toJSON();

      expect(json).toEqual({
        isActive: true,
        status: 'active',
        createdAt: '2024-01-01T10:00:00.000Z',
        lastActivatedAt: expect.any(String),
        lastDeactivatedAt: undefined,
        activeDuration: expect.any(Number),
      });
    });

    it('should serialize inactive alarm correctly', () => {
      const createdAt = new Date('2024-01-01T10:00:00.000Z');
      const alarm = new Alarm(false, createdAt);

      const json = alarm.toJSON();

      expect(json).toEqual({
        isActive: false,
        status: 'inactive',
        createdAt: '2024-01-01T10:00:00.000Z',
        lastActivatedAt: undefined,
        lastDeactivatedAt: undefined,
        lastTriggeredAt: undefined,
        activeDuration: 0,
      });
    });
  });

  describe('getters', () => {
    it('should return correct property values', () => {
      const createdAt = new Date();
      const lastActivatedAt = new Date();
      const alarm = new Alarm(true, createdAt, lastActivatedAt);

      expect(alarm.isActive).toBe(true);
      expect(alarm.createdAt).toBe(createdAt);
      expect(alarm.lastActivatedAt).toBe(lastActivatedAt);
      expect(alarm.lastDeactivatedAt).toBeUndefined();
      expect(alarm.lastTriggeredAt).toBeUndefined();
      expect(alarm.status).toBe('active');
    });
  });
});
