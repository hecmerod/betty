import { Injectable } from '@nestjs/common';
import { Observable, from } from 'rxjs';
import { ObdiiBluetoothAdapter } from '../../../infrastructure/adapters/obdii-bluetooth.adapter';
import { VehicleData } from '../../../domain/entities/vehicle-data.entity';

@Injectable()
export class ScanVehicleUseCase {
  constructor(private readonly obdiiAdapter: ObdiiBluetoothAdapter) {}

  execute(deviceAddress?: string): Observable<VehicleData> {
    return from(
      (async () => {
        let address = deviceAddress;

        // Si no se proporciona dirección, buscar dispositivo automáticamente
        if (!address) {
          address = await this.obdiiAdapter.findObdDevice();
          if (!address) {
            throw new Error('No se encontró dispositivo OBDII');
          }
        }

        return await this.obdiiAdapter.scanVehicle(address);
      })()
    );
  }
}
