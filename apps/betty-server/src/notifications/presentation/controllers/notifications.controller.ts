import {
  Controller,
  Post,
  Body,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { RegisterTokenUseCase } from '../../application/use-cases/register-token/register-token.use-case';
import { SendNotificationUseCase } from '../../application/use-cases/send-notification/send-notification.use-case';
import { SendNotificationDto, RegisterTokenDto } from '../dto/notification.dto';

@Controller('notifications')
export class NotificationsController {
  constructor(
    private readonly registerTokenUseCase: RegisterTokenUseCase,
    private readonly sendNotificationUseCase: SendNotificationUseCase
  ) {}

  @Post('register')
  async registerToken(@Body() registerTokenDto: RegisterTokenDto) {
    return await this.registerTokenUseCase.execute(registerTokenDto);
  }

  @Post('send')
  async sendNotification(@Body() sendNotificationDto: SendNotificationDto) {
    try {
      return await this.sendNotificationUseCase.execute(sendNotificationDto);
    } catch {
      throw new HttpException(
        'Error enviando notificación',
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }
}
