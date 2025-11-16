import {
  Injectable,
  OnApplicationBootstrap,
  OnModuleDestroy,
} from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { LocaltunnelAdapter } from '../../infrastructure/adapters/localtunnel.adapter';

@Injectable()
export class TunnelHealthProcess
  implements OnApplicationBootstrap, OnModuleDestroy
{
  private healthCheckInterval: NodeJS.Timeout | null = null;
  private readonly checkIntervalMs = parseInt(
    process.env.TUNNEL_HEALTH_CHECK_INTERVAL_MS,
    10
  );

  constructor(
    private readonly localtunnelAdapter: LocaltunnelAdapter,
    private readonly httpService: HttpService
  ) {}

  onApplicationBootstrap() {
    this.checkTunnelHealth();
    this.startHealthCheck();
  }

  onModuleDestroy() {
    this.stopHealthCheck();
  }

  private startHealthCheck(): void {
    this.healthCheckInterval = setInterval(async () => {
      await this.checkTunnelHealth();
    }, this.checkIntervalMs);
  }

  private stopHealthCheck(): void {
    if (!this.healthCheckInterval) return;

    clearInterval(this.healthCheckInterval);
    this.healthCheckInterval = null;
  }

  private async checkTunnelHealth(): Promise<void> {
    try {
      const healthUrl =
        (await this.localtunnelAdapter.getUrl()) + `/api/health`;

      const response = await firstValueFrom(
        this.httpService.get(healthUrl, {
          timeout: 10000,
          validateStatus: (status) => status === 200,
        })
      );

      if (response.status === 200) return;
    } catch {
      await this.handleFailure();
    }
  }

  private async handleFailure(): Promise<void> {
    const isRunning = await this.localtunnelAdapter.isRunning();

    if (!isRunning) await this.localtunnelAdapter.start();
    else await this.localtunnelAdapter.restart();
  }
}
