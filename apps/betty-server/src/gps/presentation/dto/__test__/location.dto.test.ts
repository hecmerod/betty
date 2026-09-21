import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { GetLocationsQueryDto } from '../location.dto';

describe('GetLocationsQueryDto', () => {
  const from = '2026-09-10T00:00:00.000Z';
  const to = '2026-09-10T23:59:59.000Z';

  async function validateQuery(plain: Record<string, unknown>) {
    const dto = plainToInstance(GetLocationsQueryDto, plain);
    return validate(dto);
  }

  it('should accept a valid range', async () => {
    const errors = await validateQuery({ from, to, page: '2' });

    expect(errors).toHaveLength(0);
  });

  it('should accept omitted page', async () => {
    const errors = await validateQuery({ from, to });

    expect(errors).toHaveLength(0);
  });

  it('should accept omitted datetime range', async () => {
    const errors = await validateQuery({});

    expect(errors).toHaveLength(0);
  });

  it('should reject an invalid from datetime', async () => {
    const errors = await validateQuery({ from: 'not-a-date', to });

    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('from');
    expect(errors[0].constraints).toEqual({
      isDateString: 'Invalid from datetime',
    });
  });

  it('should reject an invalid to datetime', async () => {
    const errors = await validateQuery({ from, to: 'nope' });

    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('to');
    expect(errors[0].constraints).toEqual({
      isDateString: 'Invalid to datetime',
    });
  });

  it('should reject an invalid page', async () => {
    const errors = await validateQuery({ from, to, page: '0' });

    expect(errors).toHaveLength(1);
    expect(errors[0].property).toBe('page');
    expect(errors[0].constraints).toEqual({
      min: 'Invalid page',
    });
  });
});
