import { Injectable, Inject } from '@nestjs/common';
import { Observable } from 'rxjs';
import { CameraRepository } from '../../../domain/repositories/camera.repository';
import { VideoStream } from '../../../domain/entities/video-stream.entity';
import { CAMERA_REPOSITORY } from '../../../infrastructure/ioc/symbols';

@Injectable()
export class GetVideoStreamUseCase {
  constructor(
    @Inject(CAMERA_REPOSITORY)
    private readonly cameraRepository: CameraRepository
  ) {}

  execute(): Observable<VideoStream> {
    return this.cameraRepository.startVideoStream();
  }
}
