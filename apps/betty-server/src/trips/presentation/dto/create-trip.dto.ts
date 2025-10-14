import { IsString, IsNotEmpty, MaxLength } from 'class-validator';

export class CreateTripDto {
  @IsString()
  @IsNotEmpty({ message: 'Trip name is required' })
  @MaxLength(100, { message: 'Trip name cannot exceed 100 characters' })
  name: string;
}
