import { Module } from '@nestjs/common';
import { PostsBlockController } from './posts-block.controller';
import { PostsBlockService } from './posts-block.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { PostEntity } from '../entities/post.entity';

@Module({
  imports: [TypeOrmModule.forFeature([BlockPostEntity, PostEntity])],
  controllers: [PostsBlockController],
  providers: [PostsBlockService],
})
export class PostsBlockModule {}
