import { Module, forwardRef } from '@nestjs/common';
import { GpsController } from './presentation/controllers/gps.controller';
import { LocationController } from './presentation/controllers/location.controller';
import { GetLocationUseCase } from './application/use-cases/get-location/get-location.use-case';
import { GetLocationsUseCase } from './application/use-cases/get-locations/get-locations.use-case';
import { GetLastLocationUseCase } from './application/use-cases/get-last-location/get-last-location.use-case';
import { LocationService } from './application/services/location.service';
import { GpsUsbAdapter } from './infrastructure/adapters/gps-usb.adapter';
import { PrismaLocationRepository } from './infrastructure/repositories/prisma-location.repository';
import { UsbGpsRepository } from './infrastructure/repositories/usb-gps.repository';
import {
  GPS_ADAPTER,
  GPS_REPOSITORY,
  LOCATION_REPOSITORY,
} from './infrastructure/ioc/symbols';
import { AlarmModule } from '../alarm/alarm.module';

@Module({
  imports: [forwardRef(() => AlarmModule)],
  controllers: [GpsController, LocationController],
  providers: [
    GetLocationUseCase,
    GetLocationsUseCase,
    GetLastLocationUseCase,
    LocationService,
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
    GetLastLocationUseCase,
    LocationService,
    GPS_REPOSITORY,
    LOCATION_REPOSITORY,
  ],
})
export class GpsModule {}
