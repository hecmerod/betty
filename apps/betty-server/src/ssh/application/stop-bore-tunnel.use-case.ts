import { Inject, Injectable, Logger } from '@nestjs/common';
import { BoreTunnelRepository } from '../domain/bore-tunnel-controller';
import { BORE_TUNNEL_REPOSITORY } from '../infrastructure/ioc/symbols';

@Injectable()
export class StopBoreTunnelUseCase {
  private readonly logger = new Logger(StopBoreTunnelUseCase.name);

  constructor(
    @Inject(BORE_TUNNEL_REPOSITORY)
    private readonly boreTunnelController: BoreTunnelRepository
  ) {}

  async execute(): Promise<{ success: boolean; message: string }> {
    try {
      await this.boreTunnelController.requestStop();

      return {
        success: true,
        message:
          'Stop signal sent to host. Bore tunnel will be stopped shortly.',
      };
    } catch (error) {
      throw new Error(`Failed to stop SSH tunnel: ${error.message}`);
    }
  }
}
