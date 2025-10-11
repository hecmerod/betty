import { Controller, Get } from '@nestjs/common';
import { HealthService } from './health.service';
import { Public } from '../../auth/decorators/public.decorator';

@Controller()
export class HealthController {
  constructor(private readonly appService: HealthService) {}

  @Get('health')
  @Public()
  getHealth() {
    return this.appService.getHealth();
  }
}
