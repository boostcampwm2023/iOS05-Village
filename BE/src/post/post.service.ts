import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { Repository } from 'typeorm';
import { UpdatePostDto } from './postUpdateDto';
import { validate } from 'class-validator';
import { PostImageEntity } from 'src/entities/postImage.entity';

@Injectable()
export class PostService {
  constructor(
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
    @InjectRepository(PostImageEntity)
    private postImageRepository: Repository<PostImageEntity>,
  ) {}
  async getPosts() {
    const res = await this.postRepository.find();
    const posts = [];
    res.forEach((re) => {
      const post = {
        title: re.title,
        price: re.price,
        contents: re.contents,
        post_id: re.id,
        user_id: re.user_id,
        is_request: re.is_request,
        images: re.post_images,
        start_date: re.start_date,
        end_date: re.end_date,
      };
      posts.push(post);
    });
    // console.log(posts);
    return posts;
  }

  async findPostById(postId: number) {
    try {
      const res = await this.postRepository.findOne({ where: { id: postId } });

      const post = {
        title: res.title,
        contents: res.contents,
        price: res.price,
        user_id: res.user_id,
        images: res.post_images,
        is_request: res.is_request,
        start_date: res.start_date,
        end_date: res.end_date,
      };

      return post;
    } catch {
      return null;
    }
  }

  async changeImages(postId: number, images: string[]) {
    try {
      await this.postImageRepository.delete({ post_id: postId });
      images.forEach(async (image) => {
        await this.postImageRepository.save({
          post_id: postId,
          image_url: image,
        });
      });
    } catch {
      throw new HttpException('서버 오류입니다.', 500);
    }
  }

  async changeExceptImages(postId: number, updatePostDto: UpdatePostDto) {
    try {
      await this.postRepository.update({ id: postId }, updatePostDto);
    } catch {
      throw new HttpException('서버 오류입니다.', 500);
    }
  }

  async updatePostById(postId: number, updatePostDto: UpdatePostDto) {
    const isDataExists = await this.postRepository.findOne({
      where: { id: postId },
    });

    const isChangingImages = 'images' in updatePostDto; // images 가 존재여부 확인

    try {
      if (!isDataExists) {
        return false;
      } else if (!isChangingImages) {
        await this.changeExceptImages(postId, updatePostDto);
        return true;
      } else {
        await this.changeExceptImages(postId, updatePostDto);
        await this.changeImages(postId, updatePostDto.images);
        return true;
      }
    } catch {
      return null;
    }
  }
}
