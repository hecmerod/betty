import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { IrInput } from '../../../ir/domain/enums/ir-input.enum';
import { AlarmService } from './alarm.service';

const PASSWORD_LENGTH = 4;
const PASSWORD_WINDOW_MS = 5000;

@Injectable()
export class PasswordService implements OnModuleDestroy {
  private readonly logger = new Logger(PasswordService.name);
  private digits: string[] = [];
  private windowTimeout?: NodeJS.Timeout;

  constructor(
    private readonly alarmService: AlarmService
  ) {}

  handleInput(input: IrInput): void {
    if (input === IrInput.STAR) return this.startWindow();

    if (!this.isWindowOpen() || !this.isDigit(input)) return;

    this.digits.push(input);

    if (this.digits.length < PASSWORD_LENGTH) return;

    this.complete();
  }

  onModuleDestroy(): void {
    this.reset();
  }

  private startWindow(): void {
    this.reset();
    this.windowTimeout = setTimeout(() => {
      this.logger.log('Password entry timed out');
      this.reset();
    }, PASSWORD_WINDOW_MS);
    this.logger.log('Password entry started');
  }

  private complete(): void {
    const password = this.digits.join('');
    this.reset();
    
    this.alarmService.stopSound();

    this.logger.log('Password received');
  }

  private reset(): void {
    this.digits = [];

    if (!this.windowTimeout) return;

    clearTimeout(this.windowTimeout);
    this.windowTimeout = undefined;
  }

  private isWindowOpen(): boolean {
    return this.windowTimeout !== undefined;
  }

  private isDigit(input: IrInput): boolean {
    return input >= IrInput.ZERO && input <= IrInput.NINE && input.length === 1;
  }
}
