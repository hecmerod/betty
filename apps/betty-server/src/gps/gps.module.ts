import { Module } from '@nestjs/common';
import { GpsController } from './presentation/controllers/gps.controller';
import { GetLocationUseCase } from './application/use-cases/get-location/get-location.use-case';
import { GpsUsbAdapter } from './infrastructure/adapters/gps-usb.adapter';
import { UsbGpsRepository } from './infrastructure/repositories/usb-gps.repository';
import { GPS_ADAPTER, GPS_REPOSITORY } from './infrastructure/ioc/symbols';

@Module({
  controllers: [GpsController],
  providers: [
    GetLocationUseCase,
    {
      provide: GPS_ADAPTER,
      useClass: GpsUsbAdapter,
    },
    {
      provide: GPS_REPOSITORY,
      useClass: UsbGpsRepository,
    },
  ],
  exports: [GetLocationUseCase, GPS_REPOSITORY],
})
export class GpsModule {}
