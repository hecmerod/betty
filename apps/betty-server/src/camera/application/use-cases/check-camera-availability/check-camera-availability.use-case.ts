import { Injectable, Inject } from '@nestjs/common';
import { Observable } from 'rxjs';
import { CameraRepository } from '../../../domain/repositories/camera.repository';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { CAMERA_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class CheckCameraAvailabilityUseCase {
  constructor(
    @Inject(CAMERA_REPOSITORY)
    private readonly cameraRepository: CameraRepository
  ) {}

  execute(cameraType: CameraType): Observable<boolean> {
    return this.cameraRepository.isAvailable(cameraType);
  }
}
