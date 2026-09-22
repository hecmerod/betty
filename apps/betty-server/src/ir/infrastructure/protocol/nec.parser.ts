import { IrDecode } from '../../domain/entities/ir-signal.entity';

const HEADER_MARK_US = 9000;
const HEADER_SPACE_US = 4500;
const REPEAT_SPACE_US = 2250;
const BIT_SPACE_THRESHOLD_US = 1125;
const MERGED_ZERO_HEADER_MIN_US = 5200;
const MERGED_ZERO_HEADER_MAX_US = 6800;
const TWO_ONES_MIN_US = 3000;
const TWO_ONES_MAX_US = 4600;
const DATA_BITS = 32;

export class NecParser {
  parse(pulses: number[]): IrDecode | null {
    if (pulses.length < 3) return null;
    if (!this.within(pulses[0], HEADER_MARK_US, 0.4)) return null;

    const headerSpace = pulses[1];

    if (this.within(headerSpace, REPEAT_SPACE_US, 0.4)) {
      return { protocol: 'NEC', repeat: true };
    }

    const mergedZeroHeader =
      headerSpace >= MERGED_ZERO_HEADER_MIN_US &&
      headerSpace <= MERGED_ZERO_HEADER_MAX_US;

    if (!mergedZeroHeader && !this.within(headerSpace, HEADER_SPACE_US, 0.4)) {
      return null;
    }

    let raw = 0;
    let bitCount = mergedZeroHeader ? 1 : 0;

    for (let i = 2; i + 1 < pulses.length && bitCount < DATA_BITS; i += 2) {
      const added = this.readBits(pulses[i + 1], bitCount);

      if (added === null) return null;

      raw += added.value;
      bitCount += added.count;
    }

    if (bitCount < DATA_BITS) return null;

    const address = raw & 0xff;
    const addressInverse = (raw >> 8) & 0xff;
    const command = (raw >> 16) & 0xff;
    const commandInverse = (raw >> 24) & 0xff;
    const commandValid = (command ^ commandInverse) === 0xff;
    const addressValid = (address ^ addressInverse) === 0xff;

    if (!commandValid && !addressValid) return null;

    return {
      protocol: 'NEC',
      address: addressValid ? address : raw & 0xffff,
      command,
      raw,
    };
  }

  private readBits(
    space: number,
    bitCount: number
  ): { value: number; count: number } | null {
    if (
      space >= TWO_ONES_MIN_US &&
      space <= TWO_ONES_MAX_US &&
      bitCount <= DATA_BITS - 2
    ) {
      return { value: 2 ** bitCount + 2 ** (bitCount + 1), count: 2 };
    }

    if (space >= TWO_ONES_MIN_US) return null;

    if (space >= BIT_SPACE_THRESHOLD_US) {
      return { value: 2 ** bitCount, count: 1 };
    }

    return { value: 0, count: 1 };
  }

  private within(
    value: number,
    expected: number,
    tolerance: number
  ): boolean {
    return Math.abs(value - expected) / expected <= tolerance;
  }
}
