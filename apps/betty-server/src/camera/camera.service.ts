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

  /**
   * Captura una foto desde betty-camera
   * @returns Observable con la imagen en formato Buffer
   */
  capturePhoto(): Observable<Buffer> {
    return this.httpService
      .get(`${this.cameraBaseUrl}/photo`, {
        responseType: 'arraybuffer',
        timeout: 15000, // 15 segundos para captura de foto
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

  /**
   * Obtiene el stream de video desde betty-camera
   * @returns Observable con el stream de video
   */
  getVideoStream(): Observable<NodeJS.ReadableStream> {
    return this.httpService
      .get(`${this.cameraBaseUrl}/video`, {
        responseType: 'stream',
        timeout: 0, // Sin timeout para streaming
      })
      .pipe(
        map((response: AxiosResponse<NodeJS.ReadableStream>) => {
          return response.data;
        }),
        catchError((error) => {
          this.logger.error(
            'Error starting video stream from betty-camera',
            error.message
          );
          throw new InternalServerErrorException(
            'Failed to start video stream from camera'
          );
        })
      );
  }

  /**
   * Verifica el estado de betty-camera
   * @returns Promise<boolean> true si betty-camera está disponible
   */
  async checkCameraHealth(): Promise<boolean> {
    try {
      const response = await this.httpService
        .get(`${this.cameraBaseUrl}/health`, { timeout: 5000 })
        .toPromise();

      this.logger.debug('Betty-camera health check successful');
      return response?.status === 200;
    } catch (error) {
      this.logger.warn('Betty-camera health check failed', error.message);
      return false;
    }
  }
}
