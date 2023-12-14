import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { setupSwagger } from './config/swagger.config';
import { WINSTON_MODULE_NEST_PROVIDER } from 'nest-winston';
import { winstonLogger } from './config/winston.config';
import { ValidationPipe } from '@nestjs/common';
import { HttpLoggerInterceptor } from './common/interceptor/httpLogger.interceptor';
import { WsAdapter } from '@nestjs/platform-ws';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    logger: winstonLogger,
  });
  app.useGlobalInterceptors(new HttpLoggerInterceptor());
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
