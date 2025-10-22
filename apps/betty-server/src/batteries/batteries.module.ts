import { Module } from '@nestjs/common';
import { BluetoothModule } from '../shared/bluetooth/bluetooth.module';
import { BatteriesService } from './application/batteries.service';
import { BatteriesController } from './presentation/batteries.controller';

@Module({
  imports: [BluetoothModule],
  controllers: [BatteriesController],
  providers: [BatteriesService],
  exports: [BatteriesService],
})
export class BatteriesModule {}
