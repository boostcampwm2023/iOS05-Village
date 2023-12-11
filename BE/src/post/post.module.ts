import { Module } from '@nestjs/common';
import { PostController } from './post.controller';
import { PostService } from './post.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { S3Handler } from '../common/S3Handler';
import { PostImageEntity } from '../entities/postImage.entity';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { AuthGuard } from 'src/common/guard/auth.guard';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PostEntity,
      PostImageEntity,
      BlockUserEntity,
      BlockPostEntity,
    ]),
  ],
  controllers: [PostController],
  providers: [PostService, S3Handler, AuthGuard],
})
export class PostModule {}
