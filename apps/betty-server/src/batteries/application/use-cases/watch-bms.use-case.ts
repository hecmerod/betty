import { Injectable, Inject } from '@nestjs/common';
import { Observable } from 'rxjs';
import { BmsRepository } from '../../domain/repositories/bms.repository';
import { BMS_REPOSITORY } from '../../infrastructure/ioc/symbols';
import { BatteryId } from '../../domain/value-objects/battery-id.vo';
import { BmsReading } from '../../domain/entities/bms-reading.entity';

@Injectable()
export class WatchBmsUseCase {
  constructor(
    @Inject(BMS_REPOSITORY)
    private readonly bmsRepository: BmsRepository
  ) {}

  execute(batteryId?: number): Observable<BmsReading> {
    const batteryIdVO =
      batteryId === undefined ? undefined : BatteryId.create(batteryId);

    return this.bmsRepository.watch(batteryIdVO);
  }
}
