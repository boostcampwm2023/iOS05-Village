import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const MultiPartBody = createParamDecorator(
  (data: string, ctx: ExecutionContext) => {
    const request: Request = ctx.switchToHttp().getRequest();
    const body = request.body;

    return data ? JSON.parse(body?.[data]) : body;
  },
);
