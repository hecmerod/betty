import { Inject, Injectable, Logger } from '@nestjs/common';
import { SshInfo } from '../domain/ssh-info.entity';
import { BoreTunnelRepository } from '../domain/bore-tunnel-controller';
import { BORE_TUNNEL_REPOSITORY } from '../infrastructure/ioc/symbols';

@Injectable()
export class StartBoreTunnelUseCase {
  private readonly logger = new Logger(StartBoreTunnelUseCase.name);

  constructor(
    @Inject(BORE_TUNNEL_REPOSITORY)
    private readonly fileBoreTunnelRepository: BoreTunnelRepository
  ) {}

  async execute(): Promise<{
    success: boolean;
    message: string;
    data: ReturnType<SshInfo['toJSON']> | null;
  }> {
    try {
      await this.fileBoreTunnelRepository.requestStart();

      let sshInfo: SshInfo | null = null;

      for (let i = 0; i < 15; i++) {
        await this.sleep(1000);
        sshInfo = await this.fileBoreTunnelRepository.getSshInfo();
        if (sshInfo) break;
      }

      if (!sshInfo) {
        return {
          success: true,
          message:
            'Start signal sent. Tunnel is starting, please check again in a few seconds.',
          data: null,
        };
      }

      return {
        success: true,
        message: 'SSH tunnel started successfully',
        data: sshInfo.toJSON(),
      };
    } catch (error) {
      throw new Error(`Failed to start SSH tunnel: ${error.message}`);
    }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
