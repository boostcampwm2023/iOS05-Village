import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const UserHash = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    // Guard 이후에 실행되므로 jwtToken의 유효성은 보장
    const request = ctx.switchToHttp().getRequest();
    return request.userId;
  },
);
