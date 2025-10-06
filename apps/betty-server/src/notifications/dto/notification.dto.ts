import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsObject,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class NotificationDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  body: string;

  @IsOptional()
  @IsString()
  imageUrl?: string;
}

export class SendNotificationDto {
  @IsString()
  @IsNotEmpty()
  token: string;

  @ValidateNested()
  @Type(() => NotificationDto)
  @IsNotEmpty()
  notification: NotificationDto;

  @IsOptional()
  @IsObject()
  data?: Record<string, string>;
}

export class RegisterTokenDto {
  @IsString()
  @IsNotEmpty()
  token: string;

  @IsOptional()
  @IsString()
  userId?: string;

  @IsOptional()
  @IsString()
  platform?: string;
}
