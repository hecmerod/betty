import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { CameraController } from './camera.controller';
import { CameraService } from './camera.service';

@Module({
  imports: [
    HttpModule.register({
      timeout: 30000,
      maxRedirects: 5,
    }),
  ],
  controllers: [CameraController],
  providers: [CameraService],
  exports: [CameraService],
})
export class CameraModule {}
