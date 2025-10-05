import { Controller, Get, Request } from '@nestjs/common';
import { AppService } from './app.service';
import { Public } from './auth/decorators/public.decorator';

interface AuthenticatedRequest extends Request {
  user?: {
    password: string;
    iat?: number;
    exp?: number;
  };
}

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('health')
  @Public()
  getHealth() {
    return this.appService.getHealth();
  }

  @Get('protected')
  getProtectedData(@Request() req: AuthenticatedRequest) {
    return {
      message: 'This is protected data, JWT validation successful!',
      timestamp: new Date().toISOString(),
      user: {
        authenticated: true,
        tokenIssuedAt: req.user?.iat,
        tokenExpiresAt: req.user?.exp,
      },
      server: 'Betty Server 🍓',
    };
  }
}
