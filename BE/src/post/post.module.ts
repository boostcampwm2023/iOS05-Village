import { Module } from '@nestjs/common';
import { PostController } from './post.controller';
import { PostService } from './post.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { PostImageEntity } from '../entities/postImage.entity';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { AuthGuard } from 'src/common/guard/auth.guard';
import { PostRepository } from './post.repository';
import { ImageModule } from '../image/image.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PostEntity,
      PostImageEntity,
      BlockUserEntity,
      BlockPostEntity,
    ]),
    ImageModule,
  ],
  controllers: [PostController],
  providers: [PostService, AuthGuard, PostRepository],
})
export class PostModule {}
