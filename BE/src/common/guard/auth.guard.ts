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
import { JwtPayload } from 'jsonwebtoken';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(@Inject(CACHE_MANAGER) private cacheManager: Cache) {}
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authorizationHeader = request.headers.authorization;

    if (!authorizationHeader) throw new HttpException('토큰이 없습니다.', 401);

    const accessToken = authorizationHeader.split(' ')[1];
    const isBlackList = await this.cacheManager.get(accessToken);
    if (isBlackList) {
      throw new HttpException('로그아웃된 토큰입니다.', 401);
    }
    try {
      const payload: JwtPayload = <JwtPayload>(
        jwt.verify(accessToken, process.env.JWT_SECRET)
      );
      request.userId = payload.userId;
      return true;
    } catch (err) {
      throw new HttpException('토큰이 유효하지 않습니다.', 401);
    }
  }
}
