import {
  Injectable,
  Logger,
  InternalServerErrorException,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { Observable, catchError, map } from 'rxjs';
import { AxiosResponse } from 'axios';

@Injectable()
export class CameraService {
  private readonly logger = new Logger(CameraService.name);
  private readonly cameraBaseUrl = 'http://localhost:8001/camera';

  constructor(private readonly httpService: HttpService) {}

  capturePhoto(): Observable<Buffer> {
    return this.httpService
      .get(`${this.cameraBaseUrl}/photo`, {
        responseType: 'arraybuffer',
        timeout: 15000,
      })
      .pipe(
        map((response: AxiosResponse<ArrayBuffer>) => {
          this.logger.debug('Photo captured successfully from betty-camera');
          return Buffer.from(response.data);
        }),
        catchError((error) => {
          this.logger.error(
            'Error capturing photo from betty-camera',
            error.message
          );
          throw new InternalServerErrorException(
            'Failed to capture photo from camera'
          );
        })
      );
  }

  getVideoStream(): Observable<NodeJS.ReadableStream> {
    return this.httpService
      .get(`${this.cameraBaseUrl}/video`, {
        responseType: 'stream',
        timeout: 0,
      })
      .pipe(
        map((response: AxiosResponse<NodeJS.ReadableStream>) => {
          return response.data;
        }),
        catchError(() => {
          throw new InternalServerErrorException(
            'Failed to start video stream from camera'
          );
        })
      );
  }
}
