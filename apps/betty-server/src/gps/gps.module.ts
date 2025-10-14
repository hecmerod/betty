import { Module } from '@nestjs/common';
import { GpsController } from './presentation/controllers/gps.controller';
import { GetLocationUseCase } from './application/use-cases/get-location/get-location.use-case';
import { MockGpsRepository } from './infrastructure/repositories/mock-gps.repository';
import { GPS_REPOSITORY } from './infrastructure/ioc/symbols';

@Module({
  controllers: [GpsController],
  providers: [
    GetLocationUseCase,
    {
      provide: GPS_REPOSITORY,
      useClass: MockGpsRepository,
    },
  ],
  exports: [GetLocationUseCase, GPS_REPOSITORY],
})
export class GpsModule {}
