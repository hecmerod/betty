import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { ThrottlerConfigModule } from './config/throttler/throttler-config.module';

@Module({
  imports: [ThrottlerConfigModule],
  controllers: [AppController],
})
export class AppModule {}
