import { Module } from '@nestjs/common';
import { SshController } from './presentation/ssh.controller';
import { StartBoreTunnelUseCase } from './application/start-bore-tunnel.use-case';
import { StopBoreTunnelUseCase } from './application/stop-bore-tunnel.use-case';
import { FileBoreTunnelRepository } from './infrastructure/file-bore-tunnel.repository';
import { BORE_TUNNEL_REPOSITORY } from './infrastructure/ioc/symbols';

@Module({
  controllers: [SshController],
  providers: [
    StartBoreTunnelUseCase,
    StopBoreTunnelUseCase,
    {
      provide: BORE_TUNNEL_REPOSITORY,
      useClass: FileBoreTunnelRepository,
    },
  ],
  exports: [StartBoreTunnelUseCase, StopBoreTunnelUseCase],
})
export class SshModule {}
