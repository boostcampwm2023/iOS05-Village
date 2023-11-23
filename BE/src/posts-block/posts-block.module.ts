import { Module } from '@nestjs/common';
import { PostsBlockController } from './posts-block.controller';
import { PostsBlockService } from './posts-block.service';

@Module({
  controllers: [PostsBlockController],
  providers: [PostsBlockService]
})
export class PostsBlockModule {}
