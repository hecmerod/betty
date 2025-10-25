/* eslint-disable @typescript-eslint/no-explicit-any */
import { Logger } from '@nestjs/common';
import noble from '@abandonware/noble';

export interface BmsRawData {
  deviceAddress: string;
  basicInfo: Buffer;
  cellVoltages: Buffer;
}

export class BmsBleClient {
  private readonly logger = new Logger(BmsBleClient.name);

  async readBms(macAddress: string): Promise<BmsRawData> {
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => {
        noble.stopScanning();
        reject(new Error('Timeout reading BMS'));
      }, 60000);

      const onDiscover = async (peripheral: noble.Peripheral) => {
        if (peripheral.address.toLowerCase() !== macAddress.toLowerCase())
          return;

        noble.stopScanning();
        noble.removeListener('discover', onDiscover);

        //await new Promise((resolve) => setTimeout(resolve, 500));

        try {
          await new Promise<void>((res, rej) => {
            const t = setTimeout(() => {
              rej(new Error('Connect timeout'));
            }, 50000);

            peripheral.once('connect', () => {
              clearTimeout(t);
              res();
            });

            peripheral.connect((err) => {
              if (err) {
                clearTimeout(t);
                this.logger.error(`Connect error: ${err}`);
                rej(err);
              }
            });
          });

          const chars = await new Promise<noble.Characteristic[]>(
            (res, rej) => {
              peripheral.discoverAllServicesAndCharacteristics(
                (err, _services, characteristics) => {
                  if (err) rej(err);
                  else res(characteristics || []);
                }
              );
            }
          );

          console.debug(chars);

          const rxChar = chars.find((c) => c.uuid === 'ff01');
          const txChar = chars.find((c) => c.uuid === 'ff02');

          if (!rxChar || !txChar) {
            throw new Error('Required characteristics not found');
          }

          this.logger.log('Characteristics found');

          await new Promise<void>((res, rej) => {
            rxChar.subscribe((err) => (err ? rej(err) : res()));
          });

          this.logger.log('Subscribed to notifications');

          await new Promise((resolve) => setTimeout(resolve, 1000));

          // Leer información básica (comando 0x03)
          const basicInfoData = await this.sendCommand(
            rxChar,
            txChar,
            Buffer.from([0xdd, 0xa5, 0x03, 0x00, 0xff, 0xfd, 0x77]),
            'Basic info'
          );

          // Leer voltajes de celdas (comando 0x04)
          const cellVoltagesData = await this.sendCommand(
            rxChar,
            txChar,
            Buffer.from([0xdd, 0xa5, 0x04, 0x00, 0xff, 0xfc, 0x77]),
            'Cell voltages'
          );

          peripheral.disconnect(() => {
            this.logger.log('Disconnected');
          });

          clearTimeout(timeout);

          resolve({
            deviceAddress: macAddress,
            basicInfo: basicInfoData,
            cellVoltages: cellVoltagesData,
          });
        } catch (error) {
          clearTimeout(timeout);
          peripheral.disconnect(() => {
            /* empty */
          });
          reject(error);
        }
      };

      noble.on('discover', onDiscover);

      const currentState = (noble as any).state || (noble as any)._state;
      if (currentState === 'poweredOn') {
        noble.startScanning([], false);
      } else {
        noble.once('stateChange', (state) => {
          if (state === 'poweredOn') noble.startScanning([], false);
          else {
            clearTimeout(timeout);
            reject(new Error(`BLE not ready: ${state}`));
          }
        });
      }
    });
  }

  private sendCommand(
    rxChar: noble.Characteristic,
    txChar: noble.Characteristic,
    command: Buffer,
    commandName: string
  ): Promise<Buffer> {
    return new Promise((resolve, reject) => {
      let responseData = Buffer.alloc(0);

      const dataHandler = (data: Buffer) => {
        this.logger.debug(`${commandName} data: ${data.length} bytes`);
        responseData = Buffer.concat([responseData, data]);

        if (data[data.length - 1] === 0x77) {
          rxChar.removeListener('data', dataHandler);
          resolve(responseData);
        }
      };

      const timeout = setTimeout(() => {
        rxChar.removeListener('data', dataHandler);
        if (responseData.length > 0) {
          this.logger.warn(
            `${commandName} timeout, but got ${responseData.length} bytes`
          );
          resolve(responseData);
        } else {
          reject(new Error(`${commandName} timeout`));
        }
      }, 5000);

      rxChar.on('data', dataHandler);

      txChar.write(command, false, (err) => {
        if (err) {
          clearTimeout(timeout);
          rxChar.removeListener('data', dataHandler);
          reject(err);
        } else {
          this.logger.log(`${commandName} command sent`);
        }
      });
    });
  }
}
