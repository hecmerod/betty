import { Module } from '@nestjs/common';
import { GpsController } from './presentation/controllers/gps.controller';
import { LocationController } from './presentation/controllers/location.controller';
import { GetLocationUseCase } from './application/use-cases/get-location/get-location.use-case';
import { GetLocationsUseCase } from './application/use-cases/get-locations/get-locations.use-case';
import { GpsUsbAdapter } from './infrastructure/adapters/gps-usb.adapter';
import { PrismaLocationRepository } from './infrastructure/repositories/prisma-location.repository';
import { UsbGpsRepository } from './infrastructure/repositories/usb-gps.repository';
import {
  GPS_ADAPTER,
  GPS_REPOSITORY,
  LOCATION_REPOSITORY,
} from './infrastructure/ioc/symbols';

@Module({
  controllers: [GpsController, LocationController],
  providers: [
    GetLocationUseCase,
    GetLocationsUseCase,
    {
      provide: GPS_ADAPTER,
      useClass: GpsUsbAdapter,
    },
    {
      provide: GPS_REPOSITORY,
      useClass: UsbGpsRepository,
    },
    {
      provide: LOCATION_REPOSITORY,
      useClass: PrismaLocationRepository,
    },
  ],
  exports: [
    GetLocationUseCase,
    GetLocationsUseCase,
    GPS_REPOSITORY,
    LOCATION_REPOSITORY,
  ],
})
export class GpsModule {}
