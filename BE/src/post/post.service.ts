import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { Repository } from 'typeorm';
import { UpdatePostDto } from './dto/postUpdate.dto';
import { PostImageEntity } from 'src/entities/postImage.entity';
import { S3Handler } from '../utils/S3Handler';
import { UserEntity } from '../entities/user.entity';
import { PostListDto } from './dto/postList.dto';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { BlockPostEntity } from '../entities/blockPost.entity';

@Injectable()
export class PostService {
  constructor(
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(PostImageEntity)
    private postImageRepository: Repository<PostImageEntity>,
    @InjectRepository(BlockUserEntity)
    private blockUserRepository: Repository<BlockUserEntity>,
    @InjectRepository(BlockPostEntity)
    private blockPostRepository: Repository<BlockPostEntity>,
    private s3Handler: S3Handler,
  ) {}
  makeWhereOption(query: PostListDto) {
    const where = { status: true, is_request: undefined };
    if (query.requestFilter !== undefined) {
      where.is_request = query.requestFilter !== 0;
    }
    return where;
  }

  filterBlocked(
    posts: PostEntity[],
    blockedUsers: BlockUserEntity[],
    blockedPosts: BlockPostEntity[],
  ) {
    const blockedPostsId = blockedPosts.map((blockedPost) => {
      return blockedPost.blocked_post;
    });
    const blockedUsersId = blockedUsers.map((blockedUser) => {
      return blockedUser.blockedUser.id;
    });
    return posts.filter((post) => {
      const writerId = post.user_id;
      const postId = post.id;
      return !(
        blockedPostsId.includes(postId) || blockedUsersId.includes(writerId)
      );
    });
  }
  async findPosts(query: PostListDto, userId: string) {
    const page: number = query.page === undefined ? 1 : query.page;
    const limit: number = 20;
    const offset: number = limit * (page - 1) + 1;
    const blockedUsers = await this.blockUserRepository.find({
      where: { blocker: userId },
      relations: ['blockedUser'],
    });
    const blockedPosts = await this.blockPostRepository.find({
      where: { blocker: userId },
    });
    let res = await this.postRepository.find({
      take: limit,
      skip: offset,
      where: this.makeWhereOption(query),
      relations: ['post_images'],
    });
    res = this.filterBlocked(res, blockedUsers, blockedPosts);
    const posts = [];
    res.forEach((re) => {
      const post = {
        title: re.title,
        price: re.price,
        contents: re.contents,
        post_id: re.id,
        user_id: re.user_id,
        is_request: re.is_request,
        images: re.post_images.map((post_image) => post_image.image_url),
        start_date: re.start_date,
        end_date: re.end_date,
      };
      posts.push(post);
    });
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
        post_image: res.thumbnail,
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
      for (const img of images) {
        await this.postImageRepository.save({
          post_id: postId,
          image_url: img,
        });
      }
    } catch {
      throw new HttpException('서버 오류입니다.', 500);
    }
  }

  async changeExceptImages(postId: number, updatePostDto: UpdatePostDto) {
    try {
      await this.postRepository.update({ id: postId }, updatePostDto);
    } catch (e) {
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
    } catch (e) {
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
    post.thumbnail = imageLocations.length > 0 ? imageLocations[0] : null;
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

  async deletePostById(postId: number) {
    const isDataExists = await this.postRepository.findOne({
      where: { id: postId, status: true },
    });

    if (!isDataExists) {
      return false;
    } else {
      await this.postRepository.update({ id: postId }, { status: false });
      return true;
    }
  }
}
