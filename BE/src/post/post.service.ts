import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { Repository } from 'typeorm';
import { S3Handler } from '../utils/S3Handler';
import { UserEntity } from '../entities/user.entity';
import { PostImageEntity } from '../entities/postImage.entity';

@Injectable()
export class PostService {
  constructor(
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(PostImageEntity)
    private postImageRepository: Repository<PostImageEntity>,
    private s3Handler: S3Handler,
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

  async uploadImages(files: Express.Multer.File[]): Promise<string[]> {
    const fileLocation: Array<string> = [];
    for (const file of files) {
      fileLocation.push(await this.s3Handler.uploadFile(file));
    }
    return fileLocation;
  }

  async createPost(imageLocations, createPostDto, userHash) {
    const post = new PostEntity();
    const user = await this.userRepository.findOne({
      where: { user_hash: userHash },
    });
    post.title = createPostDto.title;
    post.contents = createPostDto.contents;
    post.price = createPostDto.price;
    post.is_request = createPostDto.is_request;
    post.start_date = createPostDto.start_date;
    post.end_date = createPostDto.end_date;
    post.status = true;
    post.user_id = user.id;
    // 이미지 추가
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
}
