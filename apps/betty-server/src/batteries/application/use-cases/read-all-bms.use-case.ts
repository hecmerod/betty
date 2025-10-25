import { Injectable, Logger, Inject } from '@nestjs/common';
import { BmsRepository } from '../../domain/repositories/bms.repository';
import { BMS_REPOSITORY } from '../../infrastructure/ioc/symbols';
import { BmsReading } from '../../domain/entities/bms-reading.entity';

@Injectable()
export class ReadAllBmsUseCase {
  private readonly logger = new Logger(ReadAllBmsUseCase.name);

  constructor(
    @Inject(BMS_REPOSITORY)
    private readonly bmsRepository: BmsRepository
  ) {}

  async execute(): Promise<BmsReading[]> {
    const readings = await this.bmsRepository.readAllBms();

    return readings;
  }
}
