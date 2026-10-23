import { execFile } from 'child_process';
import { Logger } from '@nestjs/common';
import { promisify } from 'util';

const execFileAsync = promisify(execFile);
const logger = new Logger('ReleaseBmsFromBluez');

async function bluetoothctl(args: string[]): Promise<string> {
  const { stdout } = await execFileAsync('bluetoothctl', args);
  return stdout;
}

function isConnected(info: string): boolean {
  return /^[\t ]*Connected: yes/m.test(info);
}

/**
 * BlueZ (bluetoothd) often holds an LE link to JBD BMS on hci0.
 * Each BMS accepts only one client, which blocks Betty's noble stack.
 */
export async function releaseBmsFromBluez(
  macAddresses: string[]
): Promise<void> {
  for (const mac of macAddresses) {
    try {
      let info = await bluetoothctl(['info', mac]);
      if (!isConnected(info)) {
        logger.debug(`No BlueZ connection for ${mac}`);
        continue;
      }

      await bluetoothctl(['disconnect', mac]);
      info = await bluetoothctl(['info', mac]);

      if (isConnected(info)) {
        logger.warn(`BlueZ still connected to ${mac} after disconnect`);
      } else {
        logger.log(`Released ${mac} from BlueZ`);
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      if (message.includes('Device') && message.includes('not available')) {
        logger.debug(`Device ${mac} not known to BlueZ`);
      } else {
        logger.warn(`Could not release ${mac} from BlueZ: ${message}`);
      }
    }
  }
}
