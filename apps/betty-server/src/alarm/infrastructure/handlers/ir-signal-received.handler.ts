import { Injectable } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import {
  IR_SIGNAL_RECEIVED,
  IrSignalReceivedEvent,
} from '../../../ir/domain/events/ir-signal-received.event';
import { PasswordService } from '../../application/services/password.service';

@Injectable()
export class IrSignalReceivedHandler {
  constructor(private readonly irPasswordService: PasswordService) {}

  @OnEvent(IR_SIGNAL_RECEIVED)
  handle(event: IrSignalReceivedEvent): void {
    this.irPasswordService.handleInput(event.input);
  }
}
