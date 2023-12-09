import {
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { PostsBlockService } from './posts-block.service';
import { AuthGuard } from 'src/utils/auth.guard';
import { UserHash } from 'src/utils/auth.decorator';

@Controller('posts/block')
@UseGuards(AuthGuard)
export class PostsBlockController {
  constructor(private readonly postsBlockService: PostsBlockService) {}
  @Post(':id')
  async postsBlockCreate(
    @Param('id') postId: number,
    @UserHash() blockerId: string,
  ) {
    await this.postsBlockService.createPostsBlock(blockerId, postId);
  }

  @Get()
  async postsBlockList(
    @UserHash() blockerId: string,
    @Query('requestFilter') requestFilter,
  ) {
    return await this.postsBlockService.findBlockedPosts(
      blockerId,
      parseInt(requestFilter),
    );
  }

  @Delete(':id')
  async blockUserRemove(@Param('id') id: number, @UserHash() userId: string) {
    await this.postsBlockService.removeBlockPosts(id, userId);
  }
}
