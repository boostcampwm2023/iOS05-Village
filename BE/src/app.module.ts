import { Module, Logger } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WinstonModule } from 'nest-winston';
import * as process from 'process';
import * as winstonDaily from 'winston-daily-rotate-file';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { winstonOptions, dailyOption } from './config/winston.config';
import { MysqlConfigProvider } from './config/mysql.config';
import { PostModule } from './post/post.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: `${process.cwd()}/envs/${process.env.NODE_ENV}.env`,
    }),
    WinstonModule.forRoot({
      transports: [winstonOptions, new winstonDaily(dailyOption('warn'))],
    }),
    TypeOrmModule.forRootAsync({
      useClass: MysqlConfigProvider,
    }),
    PostModule,
  ],
  controllers: [AppController],
  providers: [AppService, Logger],
})
export class AppModule {}
