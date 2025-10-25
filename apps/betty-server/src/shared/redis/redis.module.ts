import { Module, Global } from '@nestjs/common';
import { RedisRepository } from './infrastructure/redis.repository';
import { REDIS_SYMBOLS } from './ioc/symbols';

@Global()
@Module({
  providers: [
    {
      provide: REDIS_SYMBOLS.RedisRepository,
      useClass: RedisRepository,
    },
  ],
  exports: [REDIS_SYMBOLS.RedisRepository],
})
export class RedisModule {}
