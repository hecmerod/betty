import { Inject, Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { IrInput } from '../../../ir/domain/enums/ir-input.enum';
import { AlarmService } from './alarm.service';
import { AlarmRepository } from '../../domain/repositories/alarm.repository';
import { ALARM_REPOSITORY } from '../../infrastructure/ioc/symbols';

const PASSWORD_LENGTH = 4;
const PASSWORD_WINDOW_MS = 5000;

@Injectable()
export class PasswordService implements OnModuleDestroy {
  private readonly logger = new Logger(PasswordService.name);
  private digits: string[] = [];
  private windowTimeout?: NodeJS.Timeout;

  constructor(
    private readonly alarmService: AlarmService,
    @Inject(ALARM_REPOSITORY)
    private readonly alarmRepository: AlarmRepository,
  ) {}

  async handleInput(input: IrInput): Promise<void> {
    if (input === IrInput.STAR) return this.startWindow();

    if (!this.isWindowOpen() || !this.isDigit(input)) return;

    this.digits.push(input);

    if (this.digits.length < PASSWORD_LENGTH) return;

    await this.complete();
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

  private async complete(): Promise<void> {
    const password = this.digits.join('');
    this.reset();    

    const alarm = await this.alarmRepository.get();

    if (password !== alarm.password) return this.logger.warn('Invalid password'); //TODO: Emit sound
    
    this.alarmService.stopSound();

    this.logger.warn('Password received'); //TODO: Emit sound
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
