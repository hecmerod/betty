import { Logger } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { IrSignal } from '../../../../domain/entities/ir-signal.entity';
import { IrInput } from '../../../../domain/enums/ir-input.enum';
import {
  IR_SIGNAL_RECEIVED,
  IrSignalReceivedEvent,
} from '../../../../domain/events/ir-signal-received.event';
import { IIrPort } from '../../../../domain/ports/ir.port';
import { ListenIrSignalService } from '../listen-ir-signal.use-case';

describe('ListenIrSignalUseCase', () => {
  let useCase: ListenIrSignalService;
  let irPort: jest.Mocked<IIrPort>;
  let eventEmitter: jest.Mocked<Pick<EventEmitter2, 'emit'>>;
  let logSpy: jest.SpyInstance;

  beforeEach(() => {
    irPort = {
      listen: jest.fn(),
      stop: jest.fn(),
    };
    eventEmitter = { emit: jest.fn() };
    logSpy = jest.spyOn(Logger.prototype, 'log').mockImplementation();
    useCase = new ListenIrSignalService(
      irPort,
      eventEmitter as unknown as EventEmitter2
    );
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('should start listening when executed', () => {
    useCase.execute();

    expect(irPort.listen).toHaveBeenCalledTimes(1);
    expect(logSpy).toHaveBeenCalledWith('Listening for IR signals');
  });

  it('should emit an event for decoded IR commands', () => {
    let onSignal: ((signal: IrSignal) => void) | undefined;
    irPort.listen.mockImplementation((callback) => {
      onSignal = callback;
    });

    useCase.execute();

    const signal = new IrSignal([9000, 4500], {
      protocol: 'NEC',
      address: 0x00,
      command: 0x40,
      raw: 0xbf40ff00,
    });
    onSignal?.(signal);

    expect(eventEmitter.emit).toHaveBeenCalledWith(
      IR_SIGNAL_RECEIVED,
      expect.objectContaining({
        input: IrInput.FIVE,
        occurredAt: expect.any(Date),
      })
    );
    expect(eventEmitter.emit.mock.calls[0][1]).toBeInstanceOf(
      IrSignalReceivedEvent
    );
  });

  it('should ignore raw pulses and repeats', () => {
    let onSignal: ((signal: IrSignal) => void) | undefined;
    irPort.listen.mockImplementation((callback) => {
      onSignal = callback;
    });

    useCase.execute();

    onSignal?.(new IrSignal([2400, 600, 600, 600]));
    onSignal?.(
      new IrSignal([9000, 2250, 560], { protocol: 'NEC', repeat: true })
    );

    expect(eventEmitter.emit).not.toHaveBeenCalled();
  });

  it('should start listening on module init and stop on destroy', () => {
    useCase.onModuleInit();
    useCase.onModuleDestroy();

    expect(irPort.listen).toHaveBeenCalledTimes(1);
    expect(irPort.stop).toHaveBeenCalledTimes(1);
  });
});
