import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpException,
  Param,
  Patch,
  Req,
  Res,
} from '@nestjs/common';
import { PostService } from './post.service';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { UpdatePostDto } from './postUpdateDto';

@Controller('posts')
@ApiTags('posts')
export class PostController {
  constructor(private readonly postService: PostService) {}

  @Get()
  async getPosts() {
    const posts = await this.postService.getPosts();
    return posts;
  }

  @Get('/:id')
  @ApiOperation({ summary: 'search for post', description: '게시글 상세 조회' })
  async postDetails(@Param('id') id: number) {
    const post = await this.postService.findPostById(id);

    if (post) {
      return post;
    } else if (post === null) {
      throw new HttpException('게시글이 존재하지 않습니다.', 404);
    } else {
      throw new HttpException('서버 오류입니다.', 500);
    }
  }

  @Patch('/:id')
  @ApiOperation({ summary: 'fix post context', description: '게시글 수정' })
  async postModify(@Param('id') id: number, @Body() body: UpdatePostDto) {
    const isFixed = await this.postService.updatePostById(id, body);

    if (isFixed) {
      return HttpCode(200);
    } else if (isFixed === null) {
      throw new HttpException('게시글이 존재하지 않습니다.', 404);
    } else {
      throw new HttpException('서버 오류입니다.', 500);
    }
  }
}
