import {
  CanActivate,
  ExecutionContext,
  HttpException,
  Inject,
  Injectable,
} from '@nestjs/common';
import * as jwt from 'jsonwebtoken';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(@Inject(CACHE_MANAGER) private cacheManager: Cache) {}
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const authorizationHeader = context.switchToHttp().getRequest()
      .headers.authorization;

    if (!authorizationHeader) throw new HttpException('토큰이 없습니다.', 401);

    const accessToken = authorizationHeader.split(' ')[1];
    const isBlackList = await this.cacheManager.get(accessToken);
    if (isBlackList) {
      throw new HttpException('로그아웃된 토큰입니다.', 401);
    }
    try {
      jwt.verify(accessToken, process.env.JWT_SECRET);
      return true;
    } catch (err) {
      return false;
    }
  }
}
