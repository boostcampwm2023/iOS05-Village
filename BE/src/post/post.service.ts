import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { Like, Repository } from 'typeorm';
import { UpdatePostDto } from './dto/postUpdate.dto';
import { PostImageEntity } from 'src/entities/postImage.entity';
import { S3Handler } from '../common/S3Handler';
import { PostListDto } from './dto/postList.dto';
import { PostRepository } from './post.repository';

@Injectable()
export class PostService {
  constructor(
    @InjectRepository(PostImageEntity)
    private postImageRepository: Repository<PostImageEntity>,
    private postRepository: PostRepository,
    private s3Handler: S3Handler,
  ) {}
  async findPosts(query: PostListDto, userId: string) {
    const posts = await this.postRepository.findExceptBlock(userId, query);
    return posts.map((filteredPost) => {
      return {
        title: filteredPost.title,
        price: filteredPost.price,
        post_id: filteredPost.id,
        user_id: filteredPost.user_hash,
        is_request: filteredPost.is_request,
        post_image: filteredPost.thumbnail,
        start_date: filteredPost.start_date,
        end_date: filteredPost.end_date,
      };
    });
  }

  async findPostById(postId: number, userId: string) {
    const post = await this.postRepository.findOneWithBlock(userId, postId);

    if (post === null) {
      throw new HttpException('없는 게시물입니다.', 404);
    }
    if (post.blocked_posts.length !== 0 || post.blocked_users.length !== 0) {
      throw new HttpException('차단한 게시물입니다.', 400);
    }
    return {
      title: post.title,
      description: post.description,
      price: post.price,
      user_id: post.user_hash,
      images: post.post_images.map((post_image) => post_image.image_url),
      is_request: post.is_request,
      start_date: post.start_date,
      end_date: post.end_date,
      post_id: post.id,
    };
  }

  async checkAuth(postId, userId) {
    const isDataExists = await this.postRepository.findOne({
      where: { id: postId },
      relations: ['user'],
    });
    if (!isDataExists) {
      throw new HttpException('게시글이 없습니다.', 404);
    }
    if (isDataExists.user.user_hash !== userId) {
      throw new HttpException('수정 권한이 없습니다.', 403);
    }
  }

  async updatePostById(
    postId: number,
    updatePostDto: UpdatePostDto,
    files: Express.Multer.File[],
    userId: string,
  ) {
    await this.checkAuth(postId, userId);
    if (files) {
      const fileLocation = await this.uploadImages(files);
      await this.createImages(fileLocation, postId);
    }

    try {
      if (updatePostDto.deleted_images !== undefined) {
        for (const deleted_image of updatePostDto.deleted_images) {
          await this.postImageRepository.softDelete({
            image_url: deleted_image,
          });
        }
      }
      delete updatePostDto.deleted_images;
      await this.postRepository.update({ id: postId }, { ...updatePostDto });
      return true;
    } catch (e) {
      console.log(e);
      return null;
    }
  }
  async uploadImages(files: Express.Multer.File[]): Promise<string[]> {
    const fileLocation: Array<string> = [];
    for (const file of files) {
      fileLocation.push(await this.s3Handler.uploadFile(file));
    }
    return fileLocation;
  }

  async createPost(imageLocations, createPostDto, userHash) {
    const post = new PostEntity();

    post.title = createPostDto.title;
    post.description = createPostDto.description;
    post.price = createPostDto.price;
    post.is_request = createPostDto.is_request;
    post.start_date = createPostDto.start_date;
    post.end_date = createPostDto.end_date;
    post.user_hash = userHash;
    post.thumbnail = imageLocations.length > 0 ? imageLocations[0] : null;
    const res = await this.postRepository.save(post);
    if (res.is_request === false) {
      await this.createImages(imageLocations, res.id);
    }
  }

  async createImages(imageLocations: Array<string>, postId: number) {
    for (const imageLocation of imageLocations) {
      const postImageEntity = new PostImageEntity();
      postImageEntity.image_url = imageLocation;
      postImageEntity.post_id = postId;
      await this.postImageRepository.save(postImageEntity);
    }
  }

  async removePost(postId: number, userId: string) {
    await this.checkAuth(postId, userId);
    await this.postRepository.softDeleteCascade(postId);
  }

  async findPostsTitles(searchKeyword: string) {
    const posts: PostEntity[] = await this.postRepository.find({
      where: { title: Like(`%${searchKeyword}%`) },
      order: {
        create_date: 'desc',
      },
    });
    const titles: string[] = posts.map((post) => post.title);
    return titles.slice(0, 5);
  }
}
