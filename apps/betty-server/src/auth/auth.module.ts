import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { JwtAuthGuard } from './jwt.guard';
import { APP_GUARD } from '@nestjs/core';

@Module({
  imports: [
    JwtModule.register({
      secret: 'betty-secret-key-2024',
      signOptions: { expiresIn: '24h' },
    }),
  ],
  providers: [
    JwtAuthGuard,
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
  exports: [JwtModule, JwtAuthGuard],
})
export class AuthModule {}
