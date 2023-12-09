import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { S3Handler } from 'src/utils/S3Handler';
import { UserEntity } from '../entities/user.entity';
import { PostEntity } from '../entities/post.entity';
import { PostImageEntity } from '../entities/postImage.entity';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { AuthGuard } from 'src/utils/auth.guard';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';
import { FcmHandler } from 'src/utils/fcmHandler';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PostEntity,
      UserEntity,
      PostImageEntity,
      BlockUserEntity,
      BlockPostEntity,
      RegistrationTokenEntity,
    ]),
  ],
  controllers: [UsersController],
  providers: [UsersService, S3Handler, AuthGuard, FcmHandler],
})
export class UsersModule {}
