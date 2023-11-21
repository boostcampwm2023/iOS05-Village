import {
  Controller,
  Get,
  HttpException,
  Param,
  Post,
  UploadedFiles,
  UseInterceptors,
  ValidationPipe,
} from '@nestjs/common';
import { PostService } from './post.service';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { FilesInterceptor } from '@nestjs/platform-express';
import { CreatePostDto } from './createPost.dto';
import { MultiPartBody } from '../utils/multiPartBody.decorator';

@Controller('posts')
@ApiTags('posts')
export class PostController {
  constructor(private readonly postService: PostService) {}

  @Get()
  async getPosts() {
    const posts = await this.postService.getPosts();
    return posts;
  }

  @Post()
  @UseInterceptors(FilesInterceptor('image', 12))
  async postsCreate(
    @UploadedFiles() files: Array<Express.Multer.File>,
    @MultiPartBody(
      'profile_info',
      new ValidationPipe({ validateCustomDecorators: true }),
    )
    createPostDto: CreatePostDto,
  ) {
    const userId: string = 'qwe';
    let imageLocation: Array<string> = [];
    if (createPostDto.is_request === false && files !== undefined) {
      imageLocation = await this.postService.uploadImages(files);
    }
    await this.postService.createPost(imageLocation, createPostDto, userId);
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
}
