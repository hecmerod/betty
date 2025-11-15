import { Injectable } from '@nestjs/common';
import { Observable, map } from 'rxjs';
import { Photo } from '../../../domain/entities/photo.entity';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { HttpCameraAdapter } from '../../../infrastructure/adapters/http-camera.adapter';
import { UsbCameraAdapter } from '../../../infrastructure/adapters/usb-camera.adapter';

@Injectable()
export class CapturePhotoUseCase {
  constructor(
    private readonly httpCameraAdapter: HttpCameraAdapter,
    private readonly usbCameraAdapter: UsbCameraAdapter
  ) {}

  execute(cameraType: CameraType, cameraIndex?: number): Observable<Photo> {
    if (
      cameraType === CameraType.INTERNAL ||
      cameraType === CameraType.EXTERNAL
    ) {
      return this.usbCameraAdapter.requestPhoto(cameraType, cameraIndex).pipe(
        map((photoBuffer: Buffer) => {
          return new Photo(photoBuffer, new Date(), 'jpeg');
        })
      );
    }

    return this.httpCameraAdapter.requestPhoto().pipe(
      map((photoBuffer: Buffer) => {
        return new Photo(photoBuffer, new Date(), 'jpeg');
      })
    );
  }
}
