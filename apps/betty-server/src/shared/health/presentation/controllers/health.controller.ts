import { Controller, Get } from '@nestjs/common';
import { GetSystemHealthUseCase } from '../../application/use-cases/get-system-health.use-case';
import { Public } from '../../../../auth/decorators/public.decorator';

@Controller()
export class HealthController {
  constructor(
    private readonly getSystemHealthUseCase: GetSystemHealthUseCase
  ) {}

  @Get('health')
  @Public()
  async getHealth() {
    return await this.getSystemHealthUseCase.execute();
  }
}
