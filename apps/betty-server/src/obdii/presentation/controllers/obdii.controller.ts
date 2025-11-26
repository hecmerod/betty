import { Controller, Get, Query, Logger } from '@nestjs/common';
import { ScanVehicleUseCase } from '../../application/use-cases/scan-vehicle/scan-vehicle.use-case';
import { firstValueFrom } from 'rxjs';

@Controller('obdii')
export class ObdiiController {
  private readonly logger = new Logger(ObdiiController.name);

  constructor(private readonly scanVehicleUseCase: ScanVehicleUseCase) {}

  @Get('scan')
  async scanVehicle(@Query('device') device?: string) {
    try {
      this.logger.log('📊 Solicitud de escaneo OBDII');

      const vehicleData = await firstValueFrom(
        this.scanVehicleUseCase.execute(device)
      );

      return {
        success: true,
        data: vehicleData.toJSON(),
      };
    } catch (error) {
      this.logger.error(`Error en escaneo: ${error.message}`);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  @Get('find-device')
  async findDevice() {
    try {
      this.logger.log('🔍 Buscando dispositivo OBDII');

      const deviceAddress = await this.scanVehicleUseCase[
        'obdiiAdapter'
      ].findObdDevice();

      if (!deviceAddress) {
        return {
          success: false,
          message: 'No se encontró dispositivo OBDII',
        };
      }

      return {
        success: true,
        device: deviceAddress,
      };
    } catch (error) {
      this.logger.error(`Error buscando dispositivo: ${error.message}`);
      return {
        success: false,
        error: error.message,
      };
    }
  }
}
