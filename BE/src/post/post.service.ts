import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { Repository } from 'typeorm';

@Injectable()
export class PostService {
  constructor(
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
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
  }
}
