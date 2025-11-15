import { Injectable } from '@nestjs/common';
import { Observable, map } from 'rxjs';
import { Photo } from '../../../domain/entities/photo.entity';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { UsbCameraAdapter } from '../../../infrastructure/adapters/usb-camera.adapter';

@Injectable()
export class CapturePhotoUseCase {
  constructor(private readonly usbCameraAdapter: UsbCameraAdapter) {}

  execute(cameraType: CameraType, cameraIndex?: number): Observable<Photo> {
    return this.usbCameraAdapter.requestPhoto(cameraType, cameraIndex).pipe(
      map((photoBuffer: Buffer) => {
        return new Photo(photoBuffer, new Date(), 'jpeg');
      })
    );
  }
}
