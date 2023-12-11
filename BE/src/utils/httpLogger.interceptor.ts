import {
  CallHandler,
  ExecutionContext,
  NestInterceptor,
  Injectable,
  Logger,
} from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { Request } from 'express';

@Injectable()
export class HttpLoggerInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');
  intercept(
    context: ExecutionContext,
    next: CallHandler<any>,
  ): Observable<any> | Promise<Observable<any>> {
    const request: Request = context.switchToHttp().getRequest();
    this.logger.debug(request.headers, 'request header');
    this.logger.debug(request.body, 'request body');

    return next.handle().pipe(
      tap((data) => {
        const request = context.switchToHttp().getRequest();
        const response = context.switchToHttp().getResponse();
        this.logger.debug(
          `${request.url} ${request.method} /${response.statusCode} ${response.statusMessage}`,
          'HTTP',
        );
      }),
      catchError((err) => {
        this.logger.error(
          `${request.url} ${request.method} /${err}`,
          'HTTP ERROR',
        );
        return throwError(err);
      }),
    );
  }
}
