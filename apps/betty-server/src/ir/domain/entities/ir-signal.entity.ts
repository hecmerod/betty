import {
  IrInput,
  NEC_COMMAND_TO_INPUT,
} from '../enums/ir-input.enum';

export interface IrDecode {
  protocol: 'NEC';
  address?: number;
  command?: number;
  raw?: number;
  repeat?: boolean;
}

export class IrSignal {
  private readonly _input?: IrInput;

  constructor(
    private readonly _pulses: number[],
    private readonly _decode?: IrDecode,
    private readonly _timestamp: Date = new Date()
  ) {
    this._input = this.parseInput(_decode);
  }

  get pulses(): number[] {
    return this._pulses;
  }

  get decode(): IrDecode | undefined {
    return this._decode;
  }

  get input(): IrInput | undefined {
    return this._input;
  }

  get timestamp(): Date {
    return this._timestamp;
  }

  toString(): string {
    if (this._input) return this._input;

    if (!this._decode) return `RAW [${this._pulses.join(', ')}]`;

    if (this._decode.repeat) return 'NEC REPEAT';

    const addressDigits = (this._decode.address ?? 0) > 0xff ? 4 : 2;
    const address = this.toHex(this._decode.address, addressDigits);
    const command = this.toHex(this._decode.command, 2);
    const raw = this.toHex(this._decode.raw, 8);

    return `NEC address=${address} command=${command} raw=${raw}`;
  }

  private parseInput(decode?: IrDecode): IrInput | undefined {
    if (!decode || decode.repeat || decode.command === undefined)
      return undefined;

    return NEC_COMMAND_TO_INPUT[decode.command];
  }

  private toHex(value: number | undefined, digits: number): string {
    if (value === undefined) return 'n/a';

    return `0x${value.toString(16).toUpperCase().padStart(digits, '0')}`;
  }
}
