import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { SetPinUseCase } from '../../application/use-cases/set-pin.use-case';
import { GetPinUseCase } from '../../application/use-cases/get-pin.use-case';
import { SetPinDto, PinStateResponseDto } from '../dto/gpio.dto';
import { Public } from '../../../shared/auth/presentation/decorators/public.decorator';

@Controller('gpio')
export class GpioController {
  constructor(
    private readonly setPinUseCase: SetPinUseCase,
    private readonly getPinUseCase: GetPinUseCase
  ) {}

  @Public()
  @Post('pin')
  @HttpCode(HttpStatus.OK)
  async setPin(@Body() setPinDto: SetPinDto): Promise<PinStateResponseDto> {
    await this.setPinUseCase.execute(setPinDto.pin, setPinDto.state);

    return {
      pin: setPinDto.pin,
      state: setPinDto.state,
      message: `Pin ${setPinDto.pin} set to ${
        setPinDto.state ? 'HIGH' : 'LOW'
      }`,
    };
  }
  @Public()
  @Get('pin/:pin')
  @HttpCode(HttpStatus.OK)
  async getPin(
    @Param('pin', ParseIntPipe) pin: number
  ): Promise<PinStateResponseDto> {
    const state = await this.getPinUseCase.execute(pin);

    return {
      pin,
      state,
      message: `Pin ${pin} is ${state ? 'HIGH' : 'LOW'}`,
    };
  }
}
