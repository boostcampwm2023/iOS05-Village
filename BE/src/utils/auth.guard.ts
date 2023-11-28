import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const requestHeader = context.switchToHttp().getRequest().headers;

    if (requestHeader) {
      try {
        jwt.verify(requestHeader.authorization, process.env.JWT_SECRET);
        return true;
      } catch (err) {
        return false;
      }
    } else {
      return false;
    }
  }
}
