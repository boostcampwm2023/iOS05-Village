import { Module, Logger, ValidationPipe } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WinstonModule } from 'nest-winston';
import * as process from 'process';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { winstonTransportsOption } from './config/winston.config';
import { MysqlConfigProvider } from './config/mysql.config';
import { PostModule } from './post/post.module';
import { APP_PIPE } from '@nestjs/core';
import { UsersModule } from './users/users.module';
import { PostsBlockModule } from './posts-block/posts-block.module';
import { UsersBlockModule } from './users-block/users-block.module';
import { LoginModule } from './login/login.module';
import { ChatModule } from './chat/chat.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: `${process.cwd()}/envs/${process.env.NODE_ENV}.env`,
    }),
    WinstonModule.forRoot({
      transports: winstonTransportsOption,
    }),
    TypeOrmModule.forRootAsync({
      useClass: MysqlConfigProvider,
    }),
    PostsBlockModule,
    UsersBlockModule,
    PostModule,
    UsersModule,
    LoginModule,
    ChatModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    Logger,
    {
      provide: APP_PIPE,
      useClass: ValidationPipe,
    },
  ],
})
export class AppModule {}
