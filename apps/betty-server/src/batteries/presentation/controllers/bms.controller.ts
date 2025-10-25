import {
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Logger,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ReadSingleBmsUseCase } from '../../application/use-cases/read-single-bms.use-case';
import { ReadAllBmsUseCase } from '../../application/use-cases/read-all-bms.use-case';
import { BmsReadingDto } from '../dtos/bms-reading.dto';
import { Public } from '../../../shared/auth/presentation/decorators/public.decorator';

@Controller('batteries')
export class BmsController {
  private readonly logger = new Logger(BmsController.name);

  constructor(
    private readonly readSingleBmsUseCase: ReadSingleBmsUseCase,
    private readonly readAllBmsUseCase: ReadAllBmsUseCase
  ) {}

  @Public()
  @Get()
  async readAllBatteries(): Promise<BmsReadingDto[]> {
    try {
      this.logger.log('Reading all batteries...');
      const readings = await this.readAllBmsUseCase.execute();
      return readings.map((r) => r.toJSON() as BmsReadingDto);
    } catch (error) {
      this.logger.error(`Error reading all batteries: ${error.message}`);
      throw new HttpException(
        {
          statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
          message: 'Failed to read batteries',
          error: error.message,
        },
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }

  @Public()
  @Get(':batteryId')
  async readBattery(
    @Param('batteryId', ParseIntPipe) batteryId: number
  ): Promise<BmsReadingDto> {
    try {
      this.logger.log(`Reading battery ${batteryId}...`);
      const reading = await this.readSingleBmsUseCase.execute(batteryId);
      return reading.toJSON() as BmsReadingDto;
    } catch (error) {
      this.logger.error(`Error reading battery ${batteryId}: ${error.message}`);

      if (error.message.includes('Invalid battery ID')) {
        throw new HttpException(
          {
            statusCode: HttpStatus.BAD_REQUEST,
            message: error.message,
          },
          HttpStatus.BAD_REQUEST
        );
      }

      throw new HttpException(
        {
          statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
          message: `Failed to read battery ${batteryId}`,
          error: error.message,
        },
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }
}
