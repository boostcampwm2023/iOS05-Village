import { Injectable } from '@nestjs/common';
import { Redis } from 'ioredis';

@Injectable()
export class RedisService {
  private client: Redis;
  constructor() {
    this.client = new Redis(6379, '101.101.211.125');
  }

  async get(key: string) {
    return await this.client.get('redis');
  }
}
