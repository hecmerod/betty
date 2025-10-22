import { Controller, Get, Param, Logger } from '@nestjs/common';
import { BatteriesService } from '../application/batteries.service';
import { Public } from '../../shared/auth/presentation/decorators/public.decorator';

@Controller('batteries')
export class BatteriesController {
  private readonly logger = new Logger(BatteriesController.name);

  constructor(private readonly batteriesService: BatteriesService) {}

  @Public()
  @Get()
  async getAllBatteries() {
    this.logger.log('GET /batteries - Obteniendo todas las baterías');
    return this.batteriesService.getAllBatteriesStatus();
  }

  @Get('summary')
  async getBatteriesSummary() {
    this.logger.log('GET /batteries/summary - Obteniendo resumen');
    return this.batteriesService.getBatteriesSummary();
  }

  @Get('scan')
  async scanBatteries() {
    this.logger.log('GET /batteries/scan - Escaneando baterías');
    const devices = await this.batteriesService.scanBatteries();
    return {
      found: devices.length,
      devices,
    };
  }

  @Get(':address')
  async getBattery(@Param('address') address: string) {
    this.logger.log(
      `GET /batteries/${address} - Obteniendo batería específica`
    );
    // Convertir - a : en la dirección MAC
    const macAddress = address.replace(/-/g, ':');
    return this.batteriesService.getBatteryStatus(macAddress);
  }
}
