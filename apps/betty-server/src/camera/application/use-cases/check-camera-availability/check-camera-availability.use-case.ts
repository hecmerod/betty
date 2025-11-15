import { Injectable } from '@nestjs/common';
import { Observable } from 'rxjs';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { UsbCameraAdapter } from '../../../infrastructure/adapters/usb-camera.adapter';

@Injectable()
export class CheckCameraAvailabilityUseCase {
  constructor(private readonly usbCameraAdapter: UsbCameraAdapter) {}

  execute(cameraType: CameraType, cameraIndex?: number): Observable<boolean> {
    return this.usbCameraAdapter.checkAvailability(cameraType, cameraIndex);
  }
}
