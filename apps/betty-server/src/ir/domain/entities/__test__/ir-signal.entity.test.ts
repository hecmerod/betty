import { IrInput } from '../../enums/ir-input.enum';
import { IrSignal } from '../ir-signal.entity';

describe('IrSignal', () => {
  it('should parse a known NEC command to an IR input', () => {
    const signal = new IrSignal([9000, 4500], {
      protocol: 'NEC',
      address: 0x00,
      command: 0x40,
      raw: 0xbf40ff00,
    });

    expect(signal.input).toBe(IrInput.FIVE);
    expect(signal.toString()).toBe('5');
  });

  it('should parse arrow and OK commands', () => {
    expect(
      new IrSignal([], { protocol: 'NEC', command: 0x18 }).input
    ).toBe(IrInput.UP);
    expect(
      new IrSignal([], { protocol: 'NEC', command: 0x52 }).input
    ).toBe(IrInput.DOWN);
    expect(
      new IrSignal([], { protocol: 'NEC', command: 0x08 }).input
    ).toBe(IrInput.LEFT);
    expect(
      new IrSignal([], { protocol: 'NEC', command: 0x5a }).input
    ).toBe(IrInput.RIGHT);
    expect(
      new IrSignal([], { protocol: 'NEC', command: 0x1c }).input
    ).toBe(IrInput.OK);
  });

  it('should parse digit, star and hash commands', () => {
    expect(
      new IrSignal([], { protocol: 'NEC', command: 0x19 }).input
    ).toBe(IrInput.ZERO);
    expect(
      new IrSignal([], { protocol: 'NEC', command: 0x16 }).input
    ).toBe(IrInput.STAR);
    expect(
      new IrSignal([], { protocol: 'NEC', command: 0x0d }).input
    ).toBe(IrInput.HASH);
  });

  it('should keep the NEC hex dump when the command is unknown', () => {
    const signal = new IrSignal([9000, 4500], {
      protocol: 'NEC',
      address: 0x00,
      command: 0xa2,
      raw: 0x5da2ff00,
    });

    expect(signal.input).toBeUndefined();
    expect(signal.toString()).toBe(
      'NEC address=0x00 command=0xA2 raw=0x5DA2FF00'
    );
  });

  it('should not parse a NEC repeat as an input', () => {
    const signal = new IrSignal([9000, 2250, 560], {
      protocol: 'NEC',
      repeat: true,
    });

    expect(signal.input).toBeUndefined();
    expect(signal.toString()).toBe('NEC REPEAT');
  });

  it('should format raw pulses when there is no decode', () => {
    const signal = new IrSignal([2400, 600]);

    expect(signal.input).toBeUndefined();
    expect(signal.toString()).toBe('RAW [2400, 600]');
  });
});
