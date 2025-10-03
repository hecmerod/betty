import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { ThrottlerConfigModule } from './config/throttler/throttler-config.module';
import { AppService } from './app.service';

@Module({
  imports: [ThrottlerConfigModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
