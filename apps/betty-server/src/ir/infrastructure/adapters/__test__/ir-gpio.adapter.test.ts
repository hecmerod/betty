import { IrGpioAdapter } from '../ir-gpio.adapter';
import { GpioConfig } from '../../../../gpio/infrastructure/config/gpio.config';

function necPulses(address: number, command: number): number[] {
  const pulses = [9000, 4500];
  const bytes = [address, address ^ 0xff, command, command ^ 0xff];

  for (const byte of bytes) {
    for (let bit = 0; bit < 8; bit++) {
      pulses.push(560);
      pulses.push(((byte >> bit) & 1) === 1 ? 1690 : 560);
    }
  }

  pulses.push(560);
  return pulses;
}

function feedPulses(adapter: IrGpioAdapter, pulses: number[]): void {
  let timestampNs = BigInt(0);

  adapter.processEdge(false, timestampNs);

  for (const durationUs of pulses) {
    timestampNs += BigInt(durationUs) * BigInt(1000);
    adapter.processEdge(true, timestampNs);
  }
}

describe('IrGpioAdapter', () => {
  let adapter: IrGpioAdapter;

  beforeEach(() => {
    adapter = new IrGpioAdapter({ irPin: 24 } as GpioConfig);
  });

  afterEach(() => {
    adapter.onModuleDestroy();
  });

  it('should ignore a single edge with no pulse width', () => {
    adapter.processEdge(false, BigInt(0));

    expect(adapter.flushFrame()).toBeNull();
  });

  it('should ignore pulses that are not a NEC frame', () => {
    feedPulses(adapter, [2400, 600, 600, 600]);

    expect(adapter.flushFrame()).toBeNull();
  });

  it('should decode a NEC frame from GPIO edges', () => {
    feedPulses(adapter, necPulses(0x00, 0xa2));

    const signal = adapter.flushFrame();

    expect(signal?.decode).toEqual({
      protocol: 'NEC',
      address: 0x00,
      command: 0xa2,
      raw: 0x5da2ff00,
    });
    expect(signal?.toString()).toBe(
      'NEC address=0x00 command=0xA2 raw=0x5DA2FF00'
    );
  });

  it('should emit a frame after a gap between bursts', () => {
    jest.useFakeTimers();
    const spy = jest.spyOn(adapter, 'flushFrame');

    try {
      feedPulses(adapter, necPulses(0x00, 0x40));
      expect(spy).not.toHaveBeenCalled();

      jest.advanceTimersByTime(25);

      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.results[0].value.decode.command).toBe(0x40);
    } finally {
      jest.useRealTimers();
    }
  });

  it('should start a new frame when the kernel timestamp gap is long', () => {
    const pulses = necPulses(0x00, 0x40);
    feedPulses(adapter, pulses);

    let timestampNs = BigInt(0);
    for (const durationUs of pulses) {
      timestampNs += BigInt(durationUs) * BigInt(1000);
    }

    const spy = jest.spyOn(adapter, 'flushFrame');
    adapter.processEdge(
      false,
      timestampNs + BigInt(20000) * BigInt(1000)
    );

    expect(spy.mock.results[0].value.decode.command).toBe(0x40);
  });
});
