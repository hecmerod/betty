import {
  Inject,
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { IrSignal } from '../../../domain/entities/ir-signal.entity';
import {
  IR_SIGNAL_RECEIVED,
  IrSignalReceivedEvent,
} from '../../../domain/events/ir-signal-received.event';
import { IIrPort } from '../../../domain/ports/ir.port';
import { IR_ADAPTER } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class ListenIrSignalService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(ListenIrSignalService.name);

  constructor(
    @Inject(IR_ADAPTER) private readonly irPort: IIrPort,
    private readonly eventEmitter: EventEmitter2
  ) {}

  onModuleInit(): void {
    this.execute();
  }

  onModuleDestroy(): void {
    this.irPort.stop();
  }

  execute(): void {
    this.irPort.listen((signal) => {
      if (!signal.input) return;
  
      this.eventEmitter.emit(
        IR_SIGNAL_RECEIVED,
        new IrSignalReceivedEvent(signal.input)
      );
    });
    
    this.logger.log('Listening for IR signals');
  }
}
