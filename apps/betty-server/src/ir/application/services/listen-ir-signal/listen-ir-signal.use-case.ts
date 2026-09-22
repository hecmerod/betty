import {
  Inject,
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { IrSignal } from '../../../domain/entities/ir-signal.entity';
import { IIrPort } from '../../../domain/ports/ir.port';
import { IR_ADAPTER } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class ListenIrSignalService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(ListenIrSignalService.name);

  constructor(@Inject(IR_ADAPTER) private readonly irPort: IIrPort) {}

  onModuleInit(): void {
    this.execute();
  }

  onModuleDestroy(): void {
    this.irPort.stop();
  }

  execute(): void {
    this.irPort.listen((signal) => this.printSignal(signal));
    this.logger.log('Listening for IR signals');
  }

  private printSignal(signal: IrSignal): void {
    if (!signal.input) return;

    this.logger.log(signal.input);
  }
}
