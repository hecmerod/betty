import { Logger } from '@nestjs/common';
import { IrSignal } from '../../../../domain/entities/ir-signal.entity';
import { IIrPort } from '../../../../domain/ports/ir.port';
import { ListenIrSignalService } from '../listen-ir-signal.use-case';

describe('ListenIrSignalUseCase', () => {
  let useCase: ListenIrSignalService;
  let irPort: jest.Mocked<IIrPort>;
  let logSpy: jest.SpyInstance;

  beforeEach(() => {
    irPort = {
      listen: jest.fn(),
      stop: jest.fn(),
    };
    logSpy = jest.spyOn(Logger.prototype, 'log').mockImplementation();
    useCase = new ListenIrSignalService(irPort);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('should start listening when executed', () => {
    useCase.execute();

    expect(irPort.listen).toHaveBeenCalledTimes(1);
    expect(logSpy).toHaveBeenCalledWith('Listening for IR signals');
  });

  it('should print decoded signals on the console', () => {
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

    expect(logSpy).toHaveBeenCalledWith('5');
  });

  it('should ignore raw pulses and repeats', () => {
    let onSignal: ((signal: IrSignal) => void) | undefined;
    irPort.listen.mockImplementation((callback) => {
      onSignal = callback;
    });

    useCase.execute();
    logSpy.mockClear();

    onSignal?.(new IrSignal([2400, 600, 600, 600]));
    onSignal?.(
      new IrSignal([9000, 2250, 560], { protocol: 'NEC', repeat: true })
    );

    expect(logSpy).not.toHaveBeenCalled();
  });

  it('should start listening on module init and stop on destroy', () => {
    useCase.onModuleInit();
    useCase.onModuleDestroy();

    expect(irPort.listen).toHaveBeenCalledTimes(1);
    expect(irPort.stop).toHaveBeenCalledTimes(1);
  });
});
