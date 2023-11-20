import { Controller, Get, Param } from '@nestjs/common';
import { PostService } from './post.service';

@Controller('post')
export class PostController {
  constructor(private readonly postService: PostService) {}

  @Get()
  async getPosts() {
    const posts = await this.postService.getPosts();
    return posts;
  }

  @Get('/:id')
  async postDetails(@Param('id') id: number) {
    const post = await this.postService.findPostById(id);
    return post;
  }
}
