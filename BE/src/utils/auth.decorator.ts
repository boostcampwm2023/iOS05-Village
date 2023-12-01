import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const UserHash = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    // Guard 이후에 실행되므로 jwtToken의 유효성은 보장

    const jwtToken = ctx.switchToHttp().getRequest().headers.authorization;
    const jwtPayload = jwtToken.split('.')[1];
    const jwtPayloadJson = JSON.parse(
      Buffer.from(jwtPayload, 'base64').toString(),
    );

    return jwtPayloadJson.user_id;
  },
);
