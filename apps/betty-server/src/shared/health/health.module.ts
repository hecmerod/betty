import { Module } from '@nestjs/common';
import { HealthController } from './presentation/controllers/health.controller';
import { GetSystemHealthUseCase } from './application/use-cases/get-system-health.use-case';

@Module({
  controllers: [HealthController],
  providers: [GetSystemHealthUseCase],
  exports: [GetSystemHealthUseCase],
})
export class HealthModule {}
