import { SshInfo } from './ssh-info.entity';

export interface BoreTunnelRepository {
  requestStart(): Promise<void>;
  requestStop(): Promise<void>;
  getSshInfo(): Promise<SshInfo | null>;
}
