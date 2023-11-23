import { Controller, Get, Param, Post } from '@nestjs/common';
import { PostsBlockService } from './posts-block.service';

@Controller('posts/block')
export class PostsBlockController {
  constructor(private readonly postsBlockService: PostsBlockService) {}
  @Post(':id')
  async postsBlockCreate(@Param('id') postId: number) {
    const blockerId = 'qwe';
    await this.postsBlockService.createPostsBlock(blockerId, postId);
  }

  @Get()
  async postsBlockList() {
    const blockerId: string = 'qwe';
    const blockedPosts =
      await this.postsBlockService.findBlockedPosts(blockerId);
    return blockedPosts;
  }
}
