import { Type } from 'class-transformer';
import { IsDateString, IsInt, IsOptional, Min } from 'class-validator';

export class GetLocationsQueryDto {
  @IsOptional()
  @IsDateString({}, { message: 'Invalid from datetime' })
  from?: string;

  @IsOptional()
  @IsDateString({}, { message: 'Invalid to datetime' })
  to?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'Invalid page' })
  @Min(1, { message: 'Invalid page' })
  page?: number;
}
