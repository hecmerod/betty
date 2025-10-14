import { Controller, Get } from '@nestjs/common';
import {
  GetLocationUseCase,
  GetLocationResponse,
} from '../../application/use-cases/get-location/get-location.use-case';

@Controller()
export class GpsController {
  constructor(private readonly getLocationUseCase: GetLocationUseCase) {}

  @Get('location')
  async getLocation(): Promise<GetLocationResponse> {
    return this.getLocationUseCase.execute();
  }
}
