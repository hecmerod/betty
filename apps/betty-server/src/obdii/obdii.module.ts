import { Module } from '@nestjs/common';
import { ObdiiController } from './presentation/controllers/obdii.controller';
import { ScanVehicleUseCase } from './application/use-cases/scan-vehicle/scan-vehicle.use-case';
import { ObdiiBluetoothAdapter } from './infrastructure/adapters/obdii-bluetooth.adapter';

@Module({
  controllers: [ObdiiController],
  providers: [ScanVehicleUseCase, ObdiiBluetoothAdapter],
  exports: [ScanVehicleUseCase],
})
export class ObdiiModule {}
