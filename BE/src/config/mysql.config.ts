import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions, TypeOrmOptionsFactory } from '@nestjs/typeorm';
import { Injectable } from '@nestjs/common';
import { UserEntity } from '../entities/user.entity';
import { PostEntity } from '../entities/post.entity';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { PostImageEntity } from '../entities/postImage.entity';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { ChatRoomEntity } from 'src/entities/chatRoom.entity';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';
import { ChatEntity } from 'src/entities/chat.entity';
import { ReportEntity } from '../entities/report.entity';

@Injectable()
export class MysqlConfigProvider implements TypeOrmOptionsFactory {
  constructor(private configService: ConfigService) {}

  createTypeOrmOptions(): TypeOrmModuleOptions {
    return {
      type: 'mysql',
      host: this.configService.get('DB_HOST'),
      port: this.configService.get<number>('DB_PORT'),
      username: this.configService.get('DB_USERNAME'),
      password: this.configService.get('DB_PASSWORD'),
      database: this.configService.get('DB_DATABASE'),
      entities: [
        UserEntity,
        PostEntity,
        PostImageEntity,
        BlockUserEntity,
        BlockPostEntity,
        ChatRoomEntity,
        RegistrationTokenEntity,
        ChatEntity,
        ReportEntity,
      ],
      synchronize: false,
    };
  }
}
