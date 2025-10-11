import {
  Controller,
  Post,
  Body,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { SendNotificationDto, RegisterTokenDto } from './dto/notification.dto';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('register')
  registerToken(@Body() registerTokenDto: RegisterTokenDto) {
    return this.notificationsService.registerToken(registerTokenDto);
  }

  @Post('send')
  async sendNotification(@Body() sendNotificationDto: SendNotificationDto) {
    try {
      return await this.notificationsService.notifyAllDevices(
        sendNotificationDto
      );
    } catch {
      throw new HttpException(
        'Error enviando notificación',
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }
}
