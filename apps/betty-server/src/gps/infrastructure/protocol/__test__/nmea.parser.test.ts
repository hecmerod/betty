import { NmeaParser } from '../nmea.parser';

describe('NmeaParser', () => {
  let parser: NmeaParser;

  beforeEach(() => {
    parser = new NmeaParser();
  });

  it('should parse a valid GGA sentence with a fix', () => {
    const result = parser.parse(
      '$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47'
    );

    expect(result).toEqual(
      expect.objectContaining({
        hasFix: true,
        latitude: expect.closeTo(48.1173, 4),
        longitude: expect.closeTo(11.516666, 4),
        altitude: 545.4,
      })
    );
    expect(result?.timestamp).toBeInstanceOf(Date);
    expect(result?.timestamp?.getUTCHours()).toBe(12);
    expect(result?.timestamp?.getUTCMinutes()).toBe(35);
    expect(result?.timestamp?.getUTCSeconds()).toBe(19);
  });

  it('should parse a valid RMC sentence with a fix', () => {
    const result = parser.parse(
      '$GPRMC,123519,A,4807.038,N,01131.000,E,022.4,084.4,230394,003.1,W*6A'
    );

    expect(result).toEqual(
      expect.objectContaining({
        hasFix: true,
        latitude: expect.closeTo(48.1173, 4),
        longitude: expect.closeTo(11.516666, 4),
      })
    );
    expect(result?.timestamp).toEqual(new Date(Date.UTC(1994, 2, 23, 12, 35, 19)));
  });

  it('should parse southern and western hemispheres', () => {
    const result = parser.parse(
      '$GNRMC,123519.00,A,3751.65,S,14507.36,E,000.0,360.0,130998,011.3,E*5B'
    );

    expect(result?.hasFix).toBe(true);
    expect(result?.latitude).toBeCloseTo(-(37 + 51.65 / 60), 5);
    expect(result?.longitude).toBeCloseTo(145 + 7.36 / 60, 5);
  });

  it('should parse GNSS GGA sentences', () => {
    const result = parser.parse(
      '$GNGGA,092204.999,4250.5589,S,14718.5084,E,1,04,24.4,12.2,M,19.7,M,,0000*53'
    );

    expect(result?.hasFix).toBe(true);
    expect(result?.latitude).toBeCloseTo(-(42 + 50.5589 / 60), 5);
    expect(result?.longitude).toBeCloseTo(147 + 18.5084 / 60, 5);
    expect(result?.altitude).toBe(12.2);
  });

  it('should return no fix for GGA without satellite lock', () => {
    const result = parser.parse(
      '$GPGGA,094043.00,,,,,0,00,99.99,,,,,,*6C'
    );

    expect(result).toEqual({ hasFix: false });
  });

  it('should return no fix for void RMC sentences from the dongle', () => {
    const result = parser.parse(
      '$GPRMC,094043.00,V,,,,,,,100926,,,N*7B'
    );

    expect(result).toEqual({ hasFix: false });
  });

  it('should ignore sentences with an invalid checksum', () => {
    const result = parser.parse(
      '$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*00'
    );

    expect(result).toBeNull();
  });

  it('should ignore unrelated NMEA sentences', () => {
    const result = parser.parse('$GPVTG,,,,,,,,,N*30');

    expect(result).toBeNull();
  });

  it('should ignore malformed lines', () => {
    expect(parser.parse('')).toBeNull();
    expect(parser.parse('not nmea')).toBeNull();
    expect(parser.parse('$GPGGA,incomplete')).toBeNull();
  });
});
