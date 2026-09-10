import { PassThrough } from 'stream';
import { GpsUsbAdapter } from '../gps-usb.adapter';

const VALID_GGA =
  '$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47';
const VALID_RMC =
  '$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A';
const VOID_GGA = '$GPGGA,094043.00,,,,,0,00,99.99,,,,,,*6C';

describe('GpsUsbAdapter', () => {
  let adapter: GpsUsbAdapter;

  beforeEach(() => {
    adapter = new GpsUsbAdapter();
  });

  afterEach(() => {
    adapter.onModuleDestroy();
  });

  it('should throw when no GPS fix has been received', async () => {
    await expect(adapter.readLocation()).rejects.toThrow(
      'No GPS fix available'
    );
  });

  it('should ignore void NMEA sentences', async () => {
    adapter.processChunk(`${VOID_GGA}\n`);

    await expect(adapter.readLocation()).rejects.toThrow(
      'No GPS fix available'
    );
  });

  it('should return a location after a valid GGA sentence', async () => {
    adapter.processChunk(`${VALID_GGA}\n`);

    const reading = await adapter.readLocation();

    expect(reading.latitude).toBeCloseTo(48.1173, 4);
    expect(reading.longitude).toBeCloseTo(11.516666, 4);
    expect(reading.altitude).toBe(545.4);
    expect(reading.timestamp).toBeInstanceOf(Date);
  });

  it('should keep altitude from GGA when a later RMC sentence has none', async () => {
    adapter.processChunk(`${VALID_GGA}\n${VALID_RMC}\n`);

    const reading = await adapter.readLocation();

    expect(reading.altitude).toBe(545.4);
    expect(reading.timestamp).toEqual(
      new Date(Date.UTC(1994, 2, 23, 12, 35, 19))
    );
  });

  it('should assemble a location from partial serial chunks', async () => {
    adapter.processChunk(VALID_GGA.slice(0, 20));
    await expect(adapter.readLocation()).rejects.toThrow(
      'No GPS fix available'
    );

    adapter.processChunk(`${VALID_GGA.slice(20)}\n`);

    const reading = await adapter.readLocation();
    expect(reading.latitude).toBeCloseTo(48.1173, 4);
  });

  it('should read NMEA sentences from an attached serial stream', async () => {
    const stream = new PassThrough();
    adapter.attachStream(stream);

    stream.write(`${VALID_GGA}\r\n`);

    const reading = await adapter.readLocation();
    expect(reading.longitude).toBeCloseTo(11.516666, 4);
  });
});
