import { Controller, Delete, Get, Param, Post } from '@nestjs/common';
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
    return await this.postsBlockService.findBlockedPosts(blockerId);
  }

  @Delete(':id')
  async blockUserRemove(@Param('id') id: number) {
    const userId = 'qwe';
    await this.postsBlockService.removeBlockPosts(id, userId);
  }
}
