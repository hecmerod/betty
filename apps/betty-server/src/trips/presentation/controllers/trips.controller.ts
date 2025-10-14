import {
  Body,
  Controller,
  Get,
  HttpException,
  HttpStatus,
  Param,
  Post,
} from '@nestjs/common';
import { CreateTripUseCase } from '../../application/use-cases/create-trip/create-trip.use-case';
import { EndTripUseCase } from '../../application/use-cases/end-trip/end-trip.use-case';
import { GetAllTripsUseCase } from '../../application/use-cases/get-all-trips/get-all-trips.use-case';
import { GetCurrentTripUseCase } from '../../application/use-cases/get-current-trip/get-current-trip.use-case';
import { GetTripByIdUseCase } from '../../application/use-cases/get-trip-by-id/get-trip-by-id.use-case';
import { HasTripInProgressUseCase } from '../../application/use-cases/has-trip-in-progress/has-trip-in-progress.use-case';
import { CreateTripDto } from '../dto/create-trip.dto';

@Controller('trips')
export class TripsController {
  constructor(
    private readonly createTripUseCase: CreateTripUseCase,
    private readonly endTripUseCase: EndTripUseCase,
    private readonly getCurrentTripUseCase: GetCurrentTripUseCase,
    private readonly getAllTripsUseCase: GetAllTripsUseCase,
    private readonly getTripByIdUseCase: GetTripByIdUseCase,
    private readonly hasTripInProgressUseCase: HasTripInProgressUseCase
  ) {}

  @Get()
  async getAllTrips() {
    const trips = await this.getAllTripsUseCase.execute();
    return trips.map((trip) => trip.toJSON());
  }

  @Get('current')
  async getCurrentTrip() {
    const trip = await this.getCurrentTripUseCase.execute(true);

    if (!trip)
      throw new HttpException('No trip in progress', HttpStatus.NOT_FOUND);

    return trip.toJSON();
  }

  @Get('in-progress')
  async hasTripInProgress() {
    return this.hasTripInProgressUseCase.execute();
  }

  @Get(':id')
  async getTripById(@Param('id') id: string) {
    const trip = await this.getTripByIdUseCase.execute(id, true);

    if (!trip) throw new HttpException('Trip not found', HttpStatus.NOT_FOUND);

    return trip.toJSON();
  }

  @Post()
  async createTrip(@Body() createTripDto: CreateTripDto) {
    try {
      const trip = await this.createTripUseCase.execute(createTripDto.name);
      return trip.toJSON();
    } catch (error) {
      if (
        error instanceof Error &&
        error.message === 'There is already a trip in progress'
      ) {
        throw new HttpException(
          'There is already a trip in progress',
          HttpStatus.CONFLICT
        );
      }
      throw error;
    }
  }

  @Post(':id/end')
  async endTrip(@Param('id') id: string) {
    try {
      const trip = await this.endTripUseCase.execute(id);
      return trip.toJSON();
    } catch (error) {
      if (error instanceof Error) {
        if (error.message === 'Trip not found') {
          throw new HttpException('Trip not found', HttpStatus.NOT_FOUND);
        }
        if (error.message === 'Trip is already completed') {
          throw new HttpException(
            'Trip is already completed',
            HttpStatus.CONFLICT
          );
        }
      }
      throw error;
    }
  }
}
