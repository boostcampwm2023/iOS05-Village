import { Module } from '@nestjs/common';
import { PostController } from './post.controller';
import { PostService } from './post.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { S3Handler } from '../utils/S3Handler';
import { UserEntity } from '../entities/user.entity';
import { PostImageEntity } from '../entities/postImage.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([PostEntity, UserEntity, PostImageEntity]),
  ],
  controllers: [PostController],
  providers: [PostService, S3Handler],
})
export class PostModule {}
