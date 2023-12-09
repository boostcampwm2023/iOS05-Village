import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { LessThan, Like, Repository } from 'typeorm';
import { UpdatePostDto } from './dto/postUpdate.dto';
import { PostImageEntity } from 'src/entities/postImage.entity';
import { S3Handler } from '../utils/S3Handler';
import { UserEntity } from '../entities/user.entity';
import { PostListDto } from './dto/postList.dto';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { FindOperator } from 'typeorm/find-options/FindOperator';

interface WhereOption {
  id: FindOperator<number>;
  is_request?: boolean;
  user_hash?: string;
  title?: FindOperator<string>;
}
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
  makeWhereOption(query: PostListDto): WhereOption {
    const cursor: FindOperator<number> =
      query.page === undefined ? undefined : LessThan(query.page);
    const where: WhereOption = { id: cursor };
    if (query.requestFilter !== undefined) {
      where.is_request = query.requestFilter !== 0;
    }
    if (query.writer !== undefined) {
      where.user_hash = query.writer;
    }
    if (query.searchKeyword !== undefined) {
      where.title = Like(`%${query.searchKeyword}%`);
    }
    return where;
  }

  async getFilteredList(userId: string) {
    const blockedUsersId: string[] = (
      await this.blockUserRepository.find({
        where: { blocker: userId },
        relations: ['blockedUser'],
      })
    ).map((blockedUser) => blockedUser.blockedUser.user_hash);

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
        blockedUsersId.includes(post.user_hash)
      );
    });
  }

  async isFiltered(post: PostEntity, userId: string) {
    const { blockedUsersId, blockedPostsId } =
      await this.getFilteredList(userId);
    return (
      blockedPostsId.includes(post.id) ||
      blockedUsersId.includes(post.user_hash)
    );
  }

  async findPosts(query: PostListDto, userId: string) {
    const limit: number = 20;

    const posts = await this.postRepository.find({
      take: limit,
      where: this.makeWhereOption(query),
      relations: ['post_images', 'user'],
      order: {
        create_date: 'desc',
      },
    });
    const filteredPosts = await this.filterBlockedPosts(userId, posts);
    return filteredPosts.map((filteredPost) => {
      return {
        title: filteredPost.title,
        price: filteredPost.price,
        description: filteredPost.description,
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
      throw new HttpException('없는 게시물입니다.', 404);
    }
    if (await this.isFiltered(post, userId)) {
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
    await this.deleteCascadingPost(postId);
    return true;
  }
  async deleteCascadingPost(postId: number) {
    await this.postImageRepository.softDelete({ post_id: postId });
    await this.blockPostRepository.softDelete({ blocked_post: postId });
    await this.postRepository.softDelete({ id: postId });
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
