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

  async getFilteredList(userId: string) {
    const blockedUsersId: number[] = (
      await this.blockUserRepository.find({
        where: { blocker: userId },
        relations: ['blockedUser'],
      })
    ).map((blockedUser) => blockedUser.blockedUser.id);

    const blockedPostsId: number[] = (
      await this.blockPostRepository.find({
        where: { blocker: userId },
      })
    ).map((blockedPost) => blockedPost.blocked_post);
    return { blockedUsersId, blockedPostsId };
  }

  async filterBlockedPosts(
    userId: string,
    posts: PostEntity[],
  ): Promise<PostEntity[]> {
    const { blockedUsersId, blockedPostsId } =
      await this.getFilteredList(userId);
    return posts.filter((post) => {
      return !(
        blockedPostsId.includes(post.id) ||
        blockedUsersId.includes(post.user_id)
      );
    });
  }

  async isFiltered(post: PostEntity, userId: string) {
    const { blockedUsersId, blockedPostsId } =
      await this.getFilteredList(userId);
    return (
      blockedPostsId.includes(post.id) || blockedUsersId.includes(post.user_id)
    );
  }

  async findPosts(query: PostListDto, userId: string) {
    const page: number = query.page === undefined ? 1 : query.page;
    const limit: number = 20;
    const offset: number = limit * (page - 1);

    const posts = await this.postRepository.find({
      take: limit,
      skip: offset,
      where: this.makeWhereOption(query),
      relations: ['post_images', 'user'],
    });
    const filteredPosts = await this.filterBlockedPosts(userId, posts);
    return filteredPosts.map((filteredPost) => {
      return {
        title: filteredPost.title,
        price: filteredPost.price,
        description: filteredPost.contents,
        post_id: filteredPost.id,
        user_id: filteredPost.user.user_hash,
        is_request: filteredPost.is_request,
        images: filteredPost.post_images.map(
          (post_image) => post_image.image_url,
        ),
        start_date: filteredPost.start_date,
        end_date: filteredPost.end_date,
      };
    });
  }

  async findPostById(postId: number, userId: string) {
    const post = await this.postRepository.findOne({
      where: { id: postId },
      relations: ['post_images', 'user'],
    });
    if (post === null) {
      throw new HttpException('없는 게시물입니다.', 400);
    }
    if (await this.isFiltered(post, userId)) {
      throw new HttpException('차단한 게시물입니다.', 400);
    }
    return {
      title: post.title,
      description: post.contents,
      price: post.price,
      user_id: post.user.user_hash,
      images: post.post_images.map((post_image) => post_image.image_url),
      is_request: post.is_request,
      start_date: post.start_date,
      end_date: post.end_date,
      post_id: post.id,
    };
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

  async updatePostById(
    postId: number,
    updatePostDto: UpdatePostDto,
    files: Express.Multer.File[],
  ) {
    const isDataExists = await this.postRepository.findOne({
      where: { id: postId },
    });

    if (!isDataExists) {
      return false;
    }

    const isChangingImages = files !== undefined;

    if (!isChangingImages) {
      await this.changeExceptImages(postId, updatePostDto);
      return true;
    } else {
      await this.changeExceptImages(postId, updatePostDto);
    }

    try {
      if (!isDataExists) {
        return false;
      } else if (!isChangingImages) {
        await this.changeExceptImages(postId, updatePostDto);
        return true;
      } else {
        await this.changeExceptImages(postId, updatePostDto);

        const imageLocations = await this.uploadImages(files);

        await this.changeImages(postId, imageLocations);
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
    post.contents = createPostDto.description;
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
