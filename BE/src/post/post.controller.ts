import {
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpException,
  Param,
  Patch,
  Post,
  Query,
  UploadedFiles,
  UseInterceptors,
  ValidationPipe,
} from '@nestjs/common';
import { PostService } from './post.service';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { UpdatePostDto } from './dto/postUpdate.dto';
import { FilesInterceptor } from '@nestjs/platform-express';
import { PostCreateDto } from './dto/postCreate.dto';
import { MultiPartBody } from '../utils/multiPartBody.decorator';
import { PostListDto } from './dto/postList.dto';
import { http } from 'winston';
import { HttpLoggerInterceptor } from 'src/utils/httpLogger.interceptor';

@Controller('posts')
@ApiTags('posts')
export class PostController {
  constructor(private readonly postService: PostService) {}

  @Get()
  async postsList(@Query() query: PostListDto) {
    const userId = 'qwe';
    const posts = await this.postService.findPosts(query, userId);
    return posts;
  }

  @Post()
  @UseInterceptors(FilesInterceptor('image', 12))
  async postsCreate(
    @UploadedFiles() files: Array<Express.Multer.File>,
    @MultiPartBody(
      'post_info',
      new ValidationPipe({ validateCustomDecorators: true }),
    )
    body: PostCreateDto,
  ) {
    const userId: string = 'qwe';
    let imageLocation: Array<string> = [];
    if (body.is_request === false && files !== undefined) {
      imageLocation = await this.postService.uploadImages(files);
    }
    await this.postService.createPost(imageLocation, body, userId);
  }

  @Get('/:id')
  @ApiOperation({ summary: 'search for post', description: '게시글 상세 조회' })
  async postDetails(@Param('id') id: number) {
    const userId = 'qwe';
    return await this.postService.findPostById(id, userId);
  }

  @Patch('/:id')
  @ApiOperation({ summary: 'fix post context', description: '게시글 수정' })
  @UseInterceptors(FilesInterceptor('image', 12))
  async postModify(
    @Param('id') id: number,
    @UploadedFiles()
    files: Array<Express.Multer.File>,
    @MultiPartBody(
      'post_info',
      new ValidationPipe({ validateCustomDecorators: true }),
    )
    body: UpdatePostDto,
  ) {
    const isFixed = await this.postService.updatePostById(id, body, files);

    if (isFixed) {
      return HttpCode(200);
    } else if (isFixed === false) {
      throw new HttpException('게시글이 존재하지 않습니다.', 404);
    } else {
      throw new HttpException('서버 오류입니다.', 500);
    }
  }

  @Delete('/:id')
  async postRemove(@Param('id') id: number) {
    const isRemoved = await this.postService.removePost(id);

    if (isRemoved) {
      return HttpCode(200);
    } else {
      throw new HttpException('게시글이 존재하지 않습니다.', 404);
    }
  }
}
