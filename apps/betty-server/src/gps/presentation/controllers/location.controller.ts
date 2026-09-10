import {
  Controller,
  Get,
  HttpException,
  HttpStatus,
  Query,
} from '@nestjs/common';
import { GetLocationsUseCase } from '../../application/use-cases/get-locations/get-locations.use-case';

@Controller('locations')
export class LocationController {
  constructor(private readonly getLocationsUseCase: GetLocationsUseCase) {}

  @Get()
  async getLocations(
    @Query('from') from: string,
    @Query('to') to: string,
    @Query('page') page?: string
  ) {
    const fromDate = new Date(from);
    const toDate = new Date(to);

    if (!from || Number.isNaN(fromDate.getTime())) {
      throw new HttpException(
        'Invalid from datetime',
        HttpStatus.BAD_REQUEST
      );
    }

    if (!to || Number.isNaN(toDate.getTime())) {
      throw new HttpException('Invalid to datetime', HttpStatus.BAD_REQUEST);
    }

    const pageNumber = page === undefined ? 1 : Number(page);

    if (!Number.isInteger(pageNumber) || pageNumber < 1) {
      throw new HttpException('Invalid page', HttpStatus.BAD_REQUEST);
    }

    const locations = await this.getLocationsUseCase.execute(
      fromDate,
      toDate,
      pageNumber
    );

    return {
      locations: locations.map((location) => location.toJSON()),
    };
  }
}
