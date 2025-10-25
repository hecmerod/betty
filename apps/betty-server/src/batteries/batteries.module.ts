import { Module } from '@nestjs/common';
import { BmsController } from './presentation/controllers/bms.controller';
import { ReadSingleBmsUseCase } from './application/use-cases/read-single-bms.use-case';
import { ReadAllBmsUseCase } from './application/use-cases/read-all-bms.use-case';
import { BMS_REPOSITORY } from './infrastructure/ioc/symbols';
import { BmsBleRepository } from './infrastructure/repositories/bms-ble.repository';

@Module({
  controllers: [BmsController],
  providers: [
    ReadSingleBmsUseCase,
    ReadAllBmsUseCase,
    {
      provide: BMS_REPOSITORY,
      useClass: BmsBleRepository,
    },
  ],
})
export class BatteriesModule {}
