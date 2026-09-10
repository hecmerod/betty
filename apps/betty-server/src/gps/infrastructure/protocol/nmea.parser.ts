export interface NmeaFixUpdate {
  hasFix: boolean;
  latitude?: number;
  longitude?: number;
  altitude?: number;
  timestamp?: Date;
}

export class NmeaParser {
  parse(sentence: string): NmeaFixUpdate | null {
    const trimmed = sentence.trim();
    if (!trimmed.startsWith('$') || !this.hasValidChecksum(trimmed))
      return null;

    const payload = trimmed.slice(1, trimmed.indexOf('*'));
    const fields = payload.split(',');
    const type = fields[0]?.slice(2);

    if (type === 'GGA') return this.parseGga(fields);
    if (type === 'RMC') return this.parseRmc(fields);

    return null;
  }

  private parseGga(fields: string[]): NmeaFixUpdate | null {
    if (fields.length < 10) return null;

    const quality = parseInt(fields[6], 10);
    if (!quality) return { hasFix: false };

    const latitude = this.parseCoordinate(fields[2], fields[3]);
    const longitude = this.parseCoordinate(fields[4], fields[5]);
    if (latitude === undefined || longitude === undefined)
      return { hasFix: false };

    const altitude = fields[9] ? parseFloat(fields[9]) : undefined;

    return {
      hasFix: true,
      latitude,
      longitude,
      altitude: Number.isFinite(altitude) ? altitude : undefined,
      timestamp: this.parseTime(fields[1]),
    };
  }

  private parseRmc(fields: string[]): NmeaFixUpdate | null {
    if (fields.length < 10) return null;
    if (fields[2] !== 'A') return { hasFix: false };

    const latitude = this.parseCoordinate(fields[3], fields[4]);
    const longitude = this.parseCoordinate(fields[5], fields[6]);
    if (latitude === undefined || longitude === undefined)
      return { hasFix: false };

    return {
      hasFix: true,
      latitude,
      longitude,
      timestamp: this.parseDateTime(fields[1], fields[9]),
    };
  }

  private parseCoordinate(
    value: string,
    hemisphere: string
  ): number | undefined {
    if (!value || !hemisphere) return undefined;

    const raw = parseFloat(value);
    if (!Number.isFinite(raw)) return undefined;

    const degrees = Math.trunc(raw / 100);
    const minutes = raw - degrees * 100;
    const decimal = degrees + minutes / 60;

    if (hemisphere === 'S' || hemisphere === 'W') return -decimal;
    if (hemisphere === 'N' || hemisphere === 'E') return decimal;

    return undefined;
  }

  private parseTime(time: string): Date | undefined {
    const parsed = this.splitTime(time);
    if (!parsed) return undefined;

    const now = new Date();
    return new Date(
      Date.UTC(
        now.getUTCFullYear(),
        now.getUTCMonth(),
        now.getUTCDate(),
        parsed.hours,
        parsed.minutes,
        parsed.seconds,
        parsed.milliseconds
      )
    );
  }

  private parseDateTime(time: string, date: string): Date | undefined {
    if (!date || date.length < 6) return this.parseTime(time);

    const day = parseInt(date.slice(0, 2), 10);
    const month = parseInt(date.slice(2, 4), 10) - 1;
    const yearDigits = parseInt(date.slice(4, 6), 10);
    const year = yearDigits >= 80 ? 1900 + yearDigits : 2000 + yearDigits;

    const parsed = this.splitTime(time);
    if (!parsed) return new Date(Date.UTC(year, month, day));

    return new Date(
      Date.UTC(
        year,
        month,
        day,
        parsed.hours,
        parsed.minutes,
        parsed.seconds,
        parsed.milliseconds
      )
    );
  }

  private splitTime(
    time: string
  ): {
    hours: number;
    minutes: number;
    seconds: number;
    milliseconds: number;
  } | undefined {
    if (!time || time.length < 6) return undefined;

    const hours = parseInt(time.slice(0, 2), 10);
    const minutes = parseInt(time.slice(2, 4), 10);
    const seconds = parseInt(time.slice(4, 6), 10);
    const fraction = time.includes('.') ? parseFloat(time.slice(6)) : 0;
    const milliseconds = Number.isFinite(fraction)
      ? Math.round(fraction * 1000)
      : 0;

    if ([hours, minutes, seconds].some((value) => Number.isNaN(value)))
      return undefined;

    return { hours, minutes, seconds, milliseconds };
  }

  private hasValidChecksum(sentence: string): boolean {
    const match = sentence.match(/^\$([^*]+)\*([0-9A-Fa-f]{2})$/);
    if (!match) return false;

    let checksum = 0;
    for (const char of match[1]) {
      checksum ^= char.charCodeAt(0);
    }

    return checksum === parseInt(match[2], 16);
  }
}
