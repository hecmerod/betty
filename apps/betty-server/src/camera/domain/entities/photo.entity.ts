export class Photo {
  constructor(
    public readonly data: Buffer,
    public readonly capturedAt: Date = new Date(),
    public readonly format = 'jpeg',
    public readonly size?: number
  ) {
    if (!data || data.length === 0) {
      throw new Error('Photo buffer cannot be empty');
    }

    if (!this.isValidFormat(format)) {
      throw new Error(`Invalid photo format: ${format}`);
    }
  }

  getSize(): number {
    return this.size || this.data.length;
  }

  isValid(): boolean {
    return this.data.length > 0 && this.isValidFormat(this.format);
  }

  getMimeType(): string {
    switch (this.format.toLowerCase()) {
      case 'jpeg':
      case 'jpg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  toJSON(): {
    capturedAt: string;
    format: string;
    size: number;
    mimeType: string;
  } {
    return {
      capturedAt: this.capturedAt.toISOString(),
      format: this.format,
      size: this.getSize(),
      mimeType: this.getMimeType(),
    };
  }

  private isValidFormat(format: string): boolean {
    const validFormats = ['jpeg', 'jpg', 'png', 'webp'];
    return validFormats.includes(format.toLowerCase());
  }
}
