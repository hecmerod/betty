import { Controller, Post, Delete } from '@nestjs/common';
import { StartBoreTunnelUseCase } from '../application/start-bore-tunnel.use-case';
import { StopBoreTunnelUseCase } from '../application/stop-bore-tunnel.use-case';

@Controller('ssh')
export class SshController {
  constructor(
    private readonly startBoreTunnelUseCase: StartBoreTunnelUseCase,
    private readonly stopBoreTunnelUseCase: StopBoreTunnelUseCase
  ) {}

  @Post('start')
  async startTunnel() {
    try {
      const result = await this.startBoreTunnelUseCase.execute();
      return result;
    } catch (error) {
      return {
        success: false,
        message: error.message,
        data: null,
      };
    }
  }

  @Delete('stop')
  async stopTunnel() {
    try {
      const result = await this.stopBoreTunnelUseCase.execute();
      return result;
    } catch (error) {
      return {
        success: false,
        message: error.message,
      };
    }
  }
}
