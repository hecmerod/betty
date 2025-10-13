import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { Observable, catchError, map } from 'rxjs';
import { AxiosResponse } from 'axios';
import { Readable } from 'stream';

@Injectable()
export class HttpCameraAdapter {
  private readonly cameraBaseUrl: string;

  constructor(private readonly httpService: HttpService) {
    this.cameraBaseUrl = process.env.CAMERA_SERVICE_URL;
  }

  requestPhoto(): Observable<Buffer> {
    return this.httpService
      .get(`${this.cameraBaseUrl}/photo`, {
        responseType: 'arraybuffer',
        timeout: 15000,
      })
      .pipe(
        map((response: AxiosResponse<ArrayBuffer>) => {
          return Buffer.from(response.data);
        }),
        catchError(() => {
          throw new InternalServerErrorException(
            'Failed to capture photo from camera'
          );
        })
      );
  }

  requestVideoStream(): Observable<Readable> {
    return this.httpService
      .get(`${this.cameraBaseUrl}/video`, {
        responseType: 'stream',
        timeout: 0,
      })
      .pipe(
        map((response: AxiosResponse<Readable>) => {
          return response.data;
        }),
        catchError(() => {
          throw new InternalServerErrorException(
            'Failed to start video stream from camera'
          );
        })
      );
  }

  checkAvailability(): Observable<boolean> {
    return this.httpService
      .get(`${this.cameraBaseUrl}/health`, {
        timeout: 5000,
      })
      .pipe(
        map(() => {
          return true;
        }),
        catchError(() => {
          return [false];
        })
      );
  }
}
