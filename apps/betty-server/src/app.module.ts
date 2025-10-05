import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { ThrottlerConfigModule } from './config/throttler/throttler-config.module';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [ThrottlerConfigModule, AuthModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
