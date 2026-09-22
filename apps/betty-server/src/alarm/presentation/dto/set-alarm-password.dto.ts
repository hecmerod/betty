import { Matches } from 'class-validator';

export class SetAlarmPasswordDto {
  @Matches(/^\d{4}$/, { message: 'Password must be 4 digits' })
  password: string;
}
