import { Module, Logger } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigModule } from '@nestjs/config';
import * as process from 'process';
import { WinstonModule } from 'nest-winston';
import { winstonOptions, dailyOption } from './utils/winston';
import * as winstonDaily from 'winston-daily-rotate-file';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: `${process.cwd()}/envs/${process.env.NODE_ENV}.env`,
    }),
    WinstonModule.forRoot({
      transports: [winstonOptions, new winstonDaily(dailyOption('warn'))],
    }),
  ],
  controllers: [AppController],
  providers: [AppService, Logger],
})
export class AppModule {}
