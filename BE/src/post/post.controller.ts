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
  UseGuards,
  UseInterceptors,
  ValidationPipe,
} from '@nestjs/common';
import { PostService } from './post.service';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { UpdatePostDto } from './dto/postUpdate.dto';
import { FilesInterceptor } from '@nestjs/platform-express';
import { PostCreateDto } from './dto/postCreate.dto';
import { MultiPartBody } from '../common/decorator/multiPartBody.decorator';
import { PostListDto } from './dto/postList.dto';
import { AuthGuard } from 'src/common/guard/auth.guard';
import { UserHash } from 'src/common/decorator/auth.decorator';
import { FilesSizeValidator } from '../common/files.validator';

@Controller('posts')
@ApiTags('posts')
@UseGuards(AuthGuard)
export class PostController {
  constructor(private readonly postService: PostService) {}

  @Get()
  async postsList(@Query() query: PostListDto, @UserHash() userId: string) {
    return await this.postService.findPosts(query, userId);
  }

  @Get('/titles')
  async postsTitlesList(@Query('searchKeyword') searchKeyword) {
    return await this.postService.findPostsTitles(searchKeyword);
  }

  @Post()
  @UseInterceptors(FilesInterceptor('image', 12))
  async postsCreate(
    @UploadedFiles(new FilesSizeValidator())
    files: Array<Express.Multer.File>,
    @MultiPartBody(
      'post_info',
      new ValidationPipe({ validateCustomDecorators: true }),
    )
    body: PostCreateDto,
    @UserHash() userId: string,
  ) {
    let imageLocation: Array<string> = [];
    if (body.is_request === false && files !== undefined) {
      imageLocation = await this.postService.uploadImages(files);
    }
    await this.postService.createPost(imageLocation, body, userId);
  }

  @Get('/:id')
  @ApiOperation({ summary: 'search for post', description: '게시글 상세 조회' })
  async postDetails(@Param('id') id: number, @UserHash() userId: string) {
    return await this.postService.findPostById(id, userId);
  }

  @Patch('/:id')
  @ApiOperation({ summary: 'fix post context', description: '게시글 수정' })
  @UseInterceptors(FilesInterceptor('image', 12))
  async postModify(
    @Param('id') id: number,
    @UploadedFiles(new FilesSizeValidator())
    files: Array<Express.Multer.File>,
    @MultiPartBody(
      'post_info',
      new ValidationPipe({ validateCustomDecorators: true }),
    )
    body: UpdatePostDto,
    @UserHash() userId,
  ) {
    const isFixed = await this.postService.updatePostById(
      id,
      body,
      files,
      userId,
    );

    if (isFixed) {
      return HttpCode(200);
    } else {
      throw new HttpException('서버 오류입니다.', 500);
    }
  }

  @Delete('/:id')
  async postRemove(@Param('id') id: number, @UserHash() userId) {
    await this.postService.removePost(id, userId);
  }
}
