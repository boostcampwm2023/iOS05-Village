import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthGuard implements CanActivate {
  canActivate(context: ExecutionContext) {
    const requestHeader = context.switchToHttp().getRequest().headers;

    if (
      requestHeader.authorization &&
      jwt.verify(requestHeader.authorization, process.env.JWT_SECRET)
    ) {
      return true;
    } else {
      return false;
    }
  }
}
