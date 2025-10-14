import { Controller, Get } from '@nestjs/common';
import { GetLocationUseCase } from '../../application/use-cases/get-location/get-location.use-case';

@Controller()
export class GpsController {
  constructor(private readonly getLocationUseCase: GetLocationUseCase) {}

  @Get('location')
  async getLocation() {
    const response = await this.getLocationUseCase.execute();

    if (response.success && response.location) {
      return {
        success: true,
        location: response.location.toJSON(),
      };
    }

    return {
      success: false,
      error: response.error,
    };
  }
}
