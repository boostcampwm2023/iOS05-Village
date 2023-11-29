import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { setupSwagger } from './config/swagger.config';
import { WINSTON_MODULE_NEST_PROVIDER, WinstonModule } from 'nest-winston';
import { dailyOption, winstonOptions } from './config/winston.config';
import * as winstonDaily from 'winston-daily-rotate-file';
import { ValidationPipe } from '@nestjs/common';
import { HttpLoggerInterceptor } from './utils/httpLogger.interceptor';
import { AuthGuard } from './utils/auth.guard';
import { WsAdapter } from '@nestjs/platform-ws';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: WinstonModule.createLogger({
      transports: [
        winstonOptions,
        new winstonDaily(dailyOption('error')),
        new winstonDaily(dailyOption('info')),
      ],
    }),
  });
  // app.useGlobalInterceptors(new HttpLoggerInterceptor());
  app.useLogger(app.get(WINSTON_MODULE_NEST_PROVIDER));
  app.useWebSocketAdapter(new WsAdapter(app));
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
    }),
  );
  setupSwagger(app);

  await app.listen(3000);
}
bootstrap();
