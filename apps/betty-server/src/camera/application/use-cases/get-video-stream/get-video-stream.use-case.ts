import { Injectable, Inject } from '@nestjs/common';
import { Observable } from 'rxjs';
import { CameraRepository } from '../../../domain/repositories/camera.repository';
import { VideoStream } from '../../../domain/entities/video-stream.entity';
import { CameraType } from '../../../domain/enums/camera-type.enum';
import { CAMERA_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class GetVideoStreamUseCase {
  constructor(
    @Inject(CAMERA_REPOSITORY)
    private readonly cameraRepository: CameraRepository
  ) {}

  execute(cameraType: CameraType): Observable<VideoStream> {
    return this.cameraRepository.startVideoStream(cameraType);
  }
}
