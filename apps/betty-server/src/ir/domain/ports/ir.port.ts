import { IrSignal } from '../entities/ir-signal.entity';

export interface IIrPort {
  listen(onSignal: (signal: IrSignal) => void): void;
  stop(): void;
}
