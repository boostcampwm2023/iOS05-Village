import { Module } from '@nestjs/common';
import { PostController } from './post.controller';
import { PostService } from './post.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { PostImageEntity } from 'src/entities/postImage.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([PostEntity]),
    TypeOrmModule.forFeature([PostImageEntity]),
  ],
  controllers: [PostController],
  providers: [PostService],
})
export class PostModule {}
