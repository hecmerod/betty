import { Injectable, Logger } from '@nestjs/common';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

@Injectable()
export class LocaltunnelAdapter {
  private readonly logger = new Logger(LocaltunnelAdapter.name);
  private readonly subdomain = process.env.LOCALTUNNEL_SUBDOMAIN;
  private readonly port = parseInt(process.env.LOCALTUNNEL_PORT, 10);

  async getUrl(): Promise<string> {
    return `https://${this.subdomain}.loca.lt`;
  }

  async isRunning(): Promise<boolean> {
    try {
      const { stdout } = await execAsync(
        `ps aux | grep "node.*lt.*--subdomain.*${this.subdomain}" | grep -v grep | awk '{print $2}'`
      );
      const pids = stdout.trim().split('\n').filter(Boolean);

      return pids.length > 0;
    } catch {
      return false;
    }
  }

  async start(): Promise<void> {
    const isRunning = await this.isRunning();

    if (isRunning) return;

    this.logger.log(
      `Initializing LocalTunnel: ${this.subdomain}:${this.port}...`
    );

    const command = `nohup lt --port ${this.port} --subdomain "${this.subdomain}" > /dev/null 2>&1 &`;
    await execAsync(command);

    await new Promise((resolve) => setTimeout(resolve, 3000));
  }

  async stop(): Promise<void> {
    try {
      await execAsync(`pkill -f "node.*lt.*--subdomain.*${this.subdomain}"`);

      await new Promise((resolve) => setTimeout(resolve, 1000));
    } catch {
      this.logger.debug('LocalTunnel was not running');
    }
  }

  async restart(): Promise<void> {
    await this.stop();
    await new Promise((resolve) => setTimeout(resolve, 2000));
    await this.start();
  }
}
