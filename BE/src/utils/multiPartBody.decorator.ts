import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const MultiPartBody = createParamDecorator(
  (data: string, ctx: ExecutionContext) => {
    const request: Request = ctx.switchToHttp().getRequest();
    const body = request.body;
    const parsedBody = body?.[data];
    if (parsedBody === undefined) {
      return undefined;
    } else {
      return JSON.parse(parsedBody);
    }
    // return data ? JSON.parse(body?.[data]) : body;
  },
);
