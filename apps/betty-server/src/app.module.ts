import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { ThrottlerConfigModule } from './config/throttler/throttler-config.module';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { CameraModule } from './camera/camera.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    ThrottlerConfigModule,
    AuthModule,
    CameraModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
