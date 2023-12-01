import {
  CanActivate,
  ExecutionContext,
  HttpException,
  Injectable,
} from '@nestjs/common';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const authorizationHeader = context.switchToHttp().getRequest()
      .headers.authorization;

    if (!authorizationHeader) throw new HttpException('토큰이 없습니다.', 401);
    else {
      try {
        jwt.verify(authorizationHeader.split(' ')[1], process.env.JWT_SECRET);
        return true;
      } catch (err) {
        return false;
      }
    }
  }
}
