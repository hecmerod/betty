import { Injectable, ConsoleLogger } from '@nestjs/common';
import { SendNotificationUseCase } from '../../notifications/application/use-cases/send-notification/send-notification.use-case';

@Injectable()
export class CustomLogger extends ConsoleLogger {
  constructor(
    private readonly sendNotificationUseCase: SendNotificationUseCase
  ) {
    super();
  }

  error(message: unknown, stack?: string, context?: string) {
    super.error(message, stack, context);

    this.sendNotificationUseCase.execute({
      notification: {
        title: '❌ Error en Betty Server',
        body: `Mensaje: ${message}\nContexto: ${context || 'N/A'}`,
      },
      data: { type: 'error_notification' },
    });
  }
}
