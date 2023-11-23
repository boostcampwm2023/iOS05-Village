import { Controller, Param, Post } from '@nestjs/common';

@Controller('posts/block')
export class PostsBlockController {
  @Post(':id')
  postsBlockCreate(@Param('id') PostId) {}
}
