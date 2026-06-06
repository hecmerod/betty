import { Controller, Get } from '@nestjs/common';

@Controller()
export class AuthController {
  @Get('auth')  
  async validate(): Promise<boolean> {
    return true;
  }
}
