import { CacheModuleOptions, CacheOptionsFactory } from '@nestjs/common/cache';
import { ConfigService } from '@nestjs/config';
import * as redisStore from 'cache-manager-ioredis';
export class RedisConfigProvider implements CacheOptionsFactory {
  configService = new ConfigService();
  createCacheOptions(): CacheModuleOptions {
    return {
      store: redisStore,
      host: this.configService.get('REDIS_HOST'),
      port: this.configService.get('REDIS_PORT'),
      password: this.configService.get('REDIS_PASSWORD'),
    };
  }
}
