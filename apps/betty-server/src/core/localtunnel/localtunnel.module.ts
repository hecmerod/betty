import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TunnelHealthProcess } from './application/processes/tunnel-health.process';
import { LocaltunnelAdapter } from './infrastructure/adapters/localtunnel.adapter';

@Module({
  imports: [HttpModule],
  providers: [TunnelHealthProcess, LocaltunnelAdapter],
  exports: [TunnelHealthProcess, LocaltunnelAdapter],
})
export class LocaltunnelModule {}
