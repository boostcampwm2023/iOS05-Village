import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { setupSwagger } from './utils/swagger';
import { WINSTON_MODULE_NEST_PROVIDER, WinstonModule } from 'nest-winston';
import { dailyOption, winstonOptions } from './utils/winston';
import * as winstonDaily from 'winston-daily-rotate-file';

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
  app.useLogger(app.get(WINSTON_MODULE_NEST_PROVIDER));
  setupSwagger(app);
  await app.listen(3000);
}
bootstrap();
