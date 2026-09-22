import { EventEmitter2 } from '@nestjs/event-emitter';
import { IrInput } from '../../../../ir/domain/enums/ir-input.enum';
import {
  ALARM_PASSWORD_RECEIVED,
  AlarmPasswordReceivedEvent,
} from '../../../domain/events/alarm-password-received.event';
import { PasswordService } from '../password.service';

describe('IrPasswordService', () => {
  let service: PasswordService;
  let eventEmitter: jest.Mocked<Pick<EventEmitter2, 'emit'>>;

  beforeEach(() => {
    jest.useFakeTimers();
    eventEmitter = { emit: jest.fn() };
    service = new PasswordService(eventEmitter as unknown as EventEmitter2);
  });

  afterEach(() => {
    service.onModuleDestroy();
    jest.useRealTimers();
  });

  it('should emit the password after star and four digits', () => {
    service.handleInput(IrInput.STAR);
    service.handleInput(IrInput.ONE);
    service.handleInput(IrInput.TWO);
    service.handleInput(IrInput.THREE);
    service.handleInput(IrInput.FOUR);

    expect(eventEmitter.emit).toHaveBeenCalledWith(
      ALARM_PASSWORD_RECEIVED,
      expect.objectContaining({ password: '1234' })
    );
    expect(eventEmitter.emit.mock.calls[0][1]).toBeInstanceOf(
      AlarmPasswordReceivedEvent
    );
  });

  it('should ignore digits outside the password window', () => {
    service.handleInput(IrInput.ONE);
    service.handleInput(IrInput.TWO);
    service.handleInput(IrInput.THREE);
    service.handleInput(IrInput.FOUR);

    expect(eventEmitter.emit).not.toHaveBeenCalled();
  });

  it('should ignore non-digit inputs while collecting the password', () => {
    service.handleInput(IrInput.STAR);
    service.handleInput(IrInput.ONE);
    service.handleInput(IrInput.OK);
    service.handleInput(IrInput.TWO);
    service.handleInput(IrInput.THREE);
    service.handleInput(IrInput.FOUR);

    expect(eventEmitter.emit).toHaveBeenCalledWith(
      ALARM_PASSWORD_RECEIVED,
      expect.objectContaining({ password: '1234' })
    );
  });

  it('should discard an incomplete password after 5 seconds', () => {
    service.handleInput(IrInput.STAR);
    service.handleInput(IrInput.ONE);
    service.handleInput(IrInput.TWO);
    jest.advanceTimersByTime(5000);

    service.handleInput(IrInput.THREE);
    service.handleInput(IrInput.FOUR);

    expect(eventEmitter.emit).not.toHaveBeenCalled();
  });

  it('should restart the window when star is pressed again', () => {
    service.handleInput(IrInput.STAR);
    service.handleInput(IrInput.ONE);
    service.handleInput(IrInput.TWO);
    service.handleInput(IrInput.STAR);
    service.handleInput(IrInput.NINE);
    service.handleInput(IrInput.EIGHT);
    service.handleInput(IrInput.SEVEN);
    service.handleInput(IrInput.SIX);

    expect(eventEmitter.emit).toHaveBeenCalledWith(
      ALARM_PASSWORD_RECEIVED,
      expect.objectContaining({ password: '9876' })
    );
  });

  it('should accept a password entered just before the window expires', () => {
    service.handleInput(IrInput.STAR);
    jest.advanceTimersByTime(4999);
    service.handleInput(IrInput.ZERO);
    service.handleInput(IrInput.ZERO);
    service.handleInput(IrInput.ZERO);
    service.handleInput(IrInput.ZERO);

    expect(eventEmitter.emit).toHaveBeenCalledWith(
      ALARM_PASSWORD_RECEIVED,
      expect.objectContaining({ password: '0000' })
    );
  });
});
