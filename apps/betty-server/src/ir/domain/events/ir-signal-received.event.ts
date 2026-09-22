import { IrInput } from '../enums/ir-input.enum';

export const IR_SIGNAL_RECEIVED = 'ir.signal.received';

export class IrSignalReceivedEvent {
  constructor(
    public readonly input: IrInput,
    public readonly occurredAt: Date = new Date()
  ) {}
}
