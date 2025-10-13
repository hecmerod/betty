import { Module, Global } from '@nestjs/common';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';

@Global()
@Module({
  imports: [
    ThrottlerModule.forRoot([
      {
        name: 'default',
        ttl: 60000, // 1 minuto
        limit: 20, // 20 requests por minuto (conservador para RPi)
      },
      {
        name: 'strict',
        ttl: 900000, // 15 minutos
        limit: 150, // 150 requests por 15 minutos
      },
      {
        name: 'burst',
        ttl: 1000, // 1 segundo
        limit: 3, // Máximo 3 requests por segundo para evitar burst
      },
    ]),
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
  exports: [ThrottlerModule],
})
export class ThrottlerConfigModule {}
