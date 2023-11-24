import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { Repository } from 'typeorm';
import { BlockPostEntity } from '../entities/blockPost.entity';

@Injectable()
export class PostsBlockService {
  constructor(
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
    @InjectRepository(BlockPostEntity)
    private blockPostRepository: Repository<BlockPostEntity>,
  ) {}
  async createPostsBlock(blockerId: string, postId: number) {
    const blockedPost = await this.postRepository.findOne({
      where: { id: postId },
    });
    if (!blockedPost) {
      throw new HttpException('없는 게시물입니다.', 404);
    }

    const isExist = await this.blockPostRepository.findOne({
      where: {
        blocker: blockerId,
        blocked_post: postId,
      },
      withDeleted: true,
    });
    if (isExist) {
      if (isExist.delete_date === null) {
        throw new HttpException('이미 차단 되었습니다.', 400);
      } else {
        await this.blockPostRepository.update(
          {
            blocker: blockerId,
            blocked_post: postId,
          },
          { delete_date: null },
        );
      }
    } else {
      const blockPostEntity = new BlockPostEntity();
      blockPostEntity.blocked_post = postId;
      blockPostEntity.blocker = blockerId;
      blockPostEntity.status = true;
      await this.blockPostRepository.save(blockPostEntity);
    }
  }

  async findBlockedPosts(blockerId: string) {
    const blockLists = await this.blockPostRepository.find({
      where: {
        blocker: blockerId,
      },
      relations: ['blockedPost'],
    });
    return blockLists.map((blockList) => {
      const blockedPost = blockList.blockedPost;
      return {
        title: blockedPost.title,
        post_image: blockedPost.thumbnail,
        post_id: blockedPost.id,
      };
    });
  }

  async removeBlockPosts(blockedPostId: number, userId: string) {
    const blockedPost = await this.blockPostRepository.findOne({
      where: { blocked_post: blockedPostId, blocker: userId },
    });
    if (!blockedPost) {
      throw new HttpException('차단된 유저가 없습니다.', 404);
    }
    await this.blockPostRepository.softDelete({
      blocked_post: blockedPostId,
      blocker: userId,
    });
  }
}
