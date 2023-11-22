import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { UserEntity } from '../entities/user.entity';
import { PostImageEntity } from '../entities/postImage.entity';
import { S3Handler } from '../utils/S3Handler';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity])],
  controllers: [UsersController],
  providers: [UsersService, S3Handler],
})
export class UsersModule {}
