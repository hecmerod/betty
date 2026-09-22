import { NecParser } from '../nec.parser';

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

describe('NecParser', () => {
  let parser: NecParser;

  beforeEach(() => {
    parser = new NecParser();
  });

  it('should decode a standard NEC frame', () => {
    const result = parser.parse(necPulses(0x00, 0xa2));

    expect(result).toEqual({
      protocol: 'NEC',
      address: 0x00,
      command: 0xa2,
      raw: 0x5da2ff00,
    });
  });

  it('should decode a NEC frame whose last bit is set', () => {
    const result = parser.parse(necPulses(0x04, 0x00));

    expect(result).toEqual({
      protocol: 'NEC',
      address: 0x04,
      command: 0x00,
      raw: 0xff00fb04,
    });
  });

  it('should decode a NEC repeat frame', () => {
    expect(parser.parse([9000, 2250, 560])).toEqual({
      protocol: 'NEC',
      repeat: true,
    });
  });

  it('should tolerate jitter around NEC timings', () => {
    const pulses = necPulses(0x04, 0x08).map((pulse) =>
      Math.round(pulse * 1.1)
    );

    const result = parser.parse(pulses);

    expect(result?.protocol).toBe('NEC');
    expect(result?.address).toBe(0x04);
    expect(result?.command).toBe(0x08);
  });

  it('should return null for an empty pulse list', () => {
    expect(parser.parse([])).toBeNull();
  });

  it('should return null when the header is not NEC', () => {
    expect(parser.parse([2400, 600, 600, 600])).toBeNull();
  });

  it('should return null when data bits are incomplete', () => {
    expect(parser.parse([9000, 4500, 560, 560, 560, 1690])).toBeNull();
  });

  it('should decode a captured frame with a merged header 0-bit', () => {
    const pulses = [
      8919, 5764, 467, 663, 470, 666, 469, 666, 467, 695, 469, 692, 408, 700,
      415, 718, 413, 1776, 469, 1906, 339, 1829, 437, 1780, 412, 1828, 469,
      1774, 434, 1780, 470, 1855, 387, 1832, 438, 767, 344, 1776, 492, 639,
      492, 912, 198, 773, 362, 1828, 410, 803, 333, 833, 303, 1776, 466, 848,
      316, 1826, 386, 1831, 440, 1779, 466, 641, 469, 1952, 317,
    ];

    const result = parser.parse(pulses);

    expect(result?.protocol).toBe('NEC');
    expect(result?.address).toBe(0x00);
    expect(result?.command).toBe(0x45);
  });

  it('should decode a captured frame with dropped marks between 1-bits', () => {
    const pulses = [
      9000, 4574, 469, 695, 492, 689, 388, 697, 470, 663, 469, 690, 444, 666,
      468, 720, 411, 645, 470, 1776, 489, 1756, 488, 1930, 317, 1772, 473, 1774,
      495, 1718, 470, 4046, 469, 1862, 370, 678, 411, 2007, 291, 665, 469, 666,
      490, 697, 360, 1886, 412, 641, 441, 746, 441, 1780, 465, 665, 523, 3966,
      439, 1830, 413, 774, 343, 1845, 413,
    ];

    const result = parser.parse(pulses);

    expect(result?.protocol).toBe('NEC');
    expect(result?.address).toBe(0x00);
    expect(result?.command).toBe(0x45);
  });
});
