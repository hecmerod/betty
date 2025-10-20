import { IsInt, Min, Max, IsBoolean } from 'class-validator';

export class SetPinDto {
  @IsInt()
  @Min(0)
  @Max(27)
  pin: number;

  @IsBoolean()
  state: boolean;
}

export class PinStateResponseDto {
  pin: number;
  state: boolean;
  message: string;
}
