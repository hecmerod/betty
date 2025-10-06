import {
  Controller,
  Post,
  Get,
  Delete,
  Body,
  Param,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { SendNotificationDto, RegisterTokenDto } from './dto/notification.dto';
import { Public } from '../auth/decorators/public.decorator';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('register')
  registerToken(@Body() registerTokenDto: RegisterTokenDto) {
    return this.notificationsService.registerToken(registerTokenDto);
  }

  @Public()
  @Post('send')
  async sendNotification(@Body() sendNotificationDto: SendNotificationDto) {
    try {
      return await this.notificationsService.sendNotification(
        sendNotificationDto
      );
    } catch (error) {
      console.error('Error enviando notificación:', error);
      throw new HttpException(
        'Error enviando notificación',
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }
}
