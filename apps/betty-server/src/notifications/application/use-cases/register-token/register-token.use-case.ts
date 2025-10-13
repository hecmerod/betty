import { Injectable, Inject } from '@nestjs/common';
import { RegisterTokenDto } from '../../../presentation/dto/notification.dto';
import { DeviceTokenRepository } from '../../../domain/repositories/device-token.repository';
import { DeviceToken } from '../../../domain/entities/device-token.entity';
import { DEVICE_TOKEN_REPOSITORY } from '../../../infrastructure/ioc/symbols';

export interface RegisterTokenResponse {
  success: boolean;
  message: string;
}

@Injectable()
export class RegisterTokenUseCase {
  constructor(
    @Inject(DEVICE_TOKEN_REPOSITORY)
    private readonly deviceTokenRepository: DeviceTokenRepository
  ) {}

  async execute(
    registerTokenDto: RegisterTokenDto
  ): Promise<RegisterTokenResponse> {
    try {
      const deviceToken = new DeviceToken(
        registerTokenDto.token,
        new Date(),
        new Date(),
        registerTokenDto.userId,
        registerTokenDto.platform
      );

      await this.deviceTokenRepository.save(deviceToken);

      return { success: true, message: 'Token registrado correctamente' };
    } catch (error) {
      return {
        success: false,
        message: `Error al registrar token: ${
          error instanceof Error ? error.message : 'Unknown error'
        }`,
      };
    }
  }
}
