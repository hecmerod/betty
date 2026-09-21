import { Controller, Get, Query, ValidationPipe } from '@nestjs/common';
import { GetLocationsUseCase } from '../../application/use-cases/get-locations/get-locations.use-case';
import { GetLocationsQueryDto } from '../dto/location.dto';

@Controller('locations')
export class LocationController {
  constructor(private readonly getLocationsUseCase: GetLocationsUseCase) {}

  @Get()
  async getLocations(
    @Query(new ValidationPipe({ transform: true }))
    query: GetLocationsQueryDto
  ) {
    const locations = await this.getLocationsUseCase.execute(
      query.from ? new Date(query.from) : undefined,
      query.to ? new Date(query.to) : undefined,
      query.page ?? 1
    );

    return {
      locations: locations.map((location) => location.toJSON()),
    };
  }
}
