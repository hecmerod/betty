import { Injectable } from '@nestjs/common';
import { Observable } from 'rxjs';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { HttpCameraAdapter } from '../../../infrastructure/adapters/http-camera.adapter';
import { UsbCameraAdapter } from '../../../infrastructure/adapters/usb-camera.adapter';

@Injectable()
export class CheckCameraAvailabilityUseCase {
  constructor(
    private readonly httpCameraAdapter: HttpCameraAdapter,
    private readonly usbCameraAdapter: UsbCameraAdapter
  ) {}

  execute(cameraType: CameraType): Observable<boolean> {
    const adapter =
      cameraType === CameraType.EXTERNAL
        ? this.usbCameraAdapter
        : this.httpCameraAdapter;

    return adapter.checkAvailability();
  }
}
