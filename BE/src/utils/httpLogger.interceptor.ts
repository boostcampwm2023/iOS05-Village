import {
  CallHandler,
  ExecutionContext,
  NestInterceptor,
  Injectable,
  Logger,
  HttpException,
} from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';

@Injectable()
export class HttpLoggerInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');
  intercept(
    context: ExecutionContext,
    next: CallHandler<any>,
  ): Observable<any> | Promise<Observable<any>> {
    const request = context.switchToHttp().getRequest();

    return next.handle().pipe(
      tap((data) => {
        const request = context.switchToHttp().getRequest();
        const response = context.switchToHttp().getResponse();
        this.logger.log(
          `${request.url} ${request.method} ${request.ip}/${response.statusCode} ${response.statusMessage}`,
          'HTTP',
        );
      }),
      catchError((err: HttpException) => {
        this.logger.log(
          `${request.url} ${request.method} ${
            request.ip
          }/${err.getStatus()} ${err.getResponse()}`,
          'HTTP ERROR',
        );
        return throwError(err);
      }),
    );
  }
}
