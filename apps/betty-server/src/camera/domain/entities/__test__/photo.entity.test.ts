import { Photo } from '../photo.entity';

describe('Photo', () => {
  describe('constructor', () => {
    it('should create a photo with valid data', () => {
      const data = Buffer.from('test image data');
      const capturedAt = new Date('2023-01-01T10:00:00Z');

      const photo = new Photo(data, capturedAt, 'jpeg');

      expect(photo.data).toBe(data);
      expect(photo.capturedAt).toBe(capturedAt);
      expect(photo.format).toBe('jpeg');
    });

    it('should create a photo with default values', () => {
      const data = Buffer.from('test image data');

      const photo = new Photo(data);

      expect(photo.data).toBe(data);
      expect(photo.capturedAt).toBeInstanceOf(Date);
      expect(photo.format).toBe('jpeg');
    });

    it('should throw error if attempting to create with null buffer', () => {
      expect(() => new Photo(Buffer.alloc(0), new Date(), 'jpeg')).toThrow(
        'Photo buffer cannot be empty'
      );
    });

    it('should throw error for invalid format', () => {
      const data = Buffer.from('test image data');

      expect(() => new Photo(data, new Date(), 'invalid')).toThrow(
        'Invalid photo format: invalid'
      );
    });
  });

  describe('getSize', () => {
    it('should return data length when size is not provided', () => {
      const data = Buffer.from('test image data');
      const photo = new Photo(data);

      expect(photo.getSize()).toBe(data.length);
    });

    it('should return provided size when available', () => {
      const data = Buffer.from('test image data');
      const size = 1024;
      const photo = new Photo(data, new Date(), 'jpeg', size);

      expect(photo.getSize()).toBe(size);
    });
  });

  describe('isValid', () => {
    it('should return true for valid photo', () => {
      const data = Buffer.from('test image data');
      const photo = new Photo(data, new Date(), 'jpeg');

      expect(photo.isValid()).toBe(true);
    });

    it('should return false for empty data through constructor validation', () => {
      expect(() => new Photo(Buffer.alloc(0))).toThrow(
        'Photo buffer cannot be empty'
      );
    });
  });

  describe('getMimeType', () => {
    it('should return correct MIME type for jpeg', () => {
      const photo = new Photo(Buffer.from('test'), new Date(), 'jpeg');

      expect(photo.getMimeType()).toBe('image/jpeg');
    });

    it('should return correct MIME type for png', () => {
      const photo = new Photo(Buffer.from('test'), new Date(), 'png');

      expect(photo.getMimeType()).toBe('image/png');
    });

    it('should return correct MIME type for webp', () => {
      const photo = new Photo(Buffer.from('test'), new Date(), 'webp');

      expect(photo.getMimeType()).toBe('image/webp');
    });

    it('should return default MIME type for unknown format through constructor', () => {
      expect(
        () => new Photo(Buffer.from('test'), new Date(), 'unknown')
      ).toThrow('Invalid photo format: unknown');
    });
  });

  describe('toJSON', () => {
    it('should serialize photo to JSON without binary data', () => {
      const data = Buffer.from('test image data');
      const capturedAt = new Date('2023-01-01T10:00:00Z');
      const photo = new Photo(data, capturedAt, 'jpeg', 1024);

      const json = photo.toJSON();

      expect(json).toEqual({
        capturedAt: '2023-01-01T10:00:00.000Z',
        format: 'jpeg',
        size: 1024,
        mimeType: 'image/jpeg',
      });
    });
  });
});
