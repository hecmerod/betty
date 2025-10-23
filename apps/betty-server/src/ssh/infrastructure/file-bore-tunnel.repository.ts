import { Injectable } from '@nestjs/common';
import { writeFile, mkdir, readFile } from 'fs/promises';
import { existsSync } from 'fs';
import { dirname } from 'path';
import { BoreTunnelRepository } from '../domain/bore-tunnel-controller';
import { SshInfo } from '../domain/ssh-info.entity';

@Injectable()
export class FileBoreTunnelRepository implements BoreTunnelRepository {
  private readonly controlFile: string;
  private readonly sshUrlFile: string;

  constructor() {
    this.controlFile = process.env.BORE_CONTROL_FILE;
    this.sshUrlFile = process.env.BORE_SSH_URL_FILE;
  }

  async requestStart(): Promise<void> {
    await this.writeControlCommand('START');
  }

  async requestStop(): Promise<void> {
    await this.writeControlCommand('STOP');
  }

  async getSshInfo(): Promise<SshInfo | null> {
    try {
      if (!existsSync(this.sshUrlFile)) return null;

      const content = await readFile(this.sshUrlFile, 'utf-8');
      const command = content.trim();

      if (command.startsWith('ERROR:')) return null;

      if (!command.startsWith('ssh ')) return null;

      const sshInfo = SshInfo.fromCommand(command);

      return sshInfo;
    } catch {
      return null;
    }
  }

  private async writeControlCommand(command: string): Promise<void> {
    try {
      const dir = dirname(this.controlFile);
      if (!existsSync(dir)) await mkdir(dir, { recursive: true });

      await writeFile(this.controlFile, command, 'utf-8');
    } catch (error) {
      throw new Error(`Failed to write control command: ${error.message}`);
    }
  }
}
