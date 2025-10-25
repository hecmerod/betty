import { Injectable, Logger, Inject } from '@nestjs/common';
import { BmsRepository } from '../../domain/repositories/bms.repository';
import { BMS_REPOSITORY } from '../../infrastructure/ioc/symbols';
import { BatteryId } from '../../domain/value-objects/battery-id.vo';
import { BmsReading } from '../../domain/entities/bms-reading.entity';

@Injectable()
export class ReadSingleBmsUseCase {
  private readonly logger = new Logger(ReadSingleBmsUseCase.name);

  constructor(
    @Inject(BMS_REPOSITORY)
    private readonly bmsRepository: BmsRepository
  ) {}

  async execute(batteryId: number): Promise<BmsReading> {
    const batteryIdVO = BatteryId.create(batteryId);

    const reading = await this.bmsRepository.readBms(batteryIdVO);

    return reading;
  }
}
