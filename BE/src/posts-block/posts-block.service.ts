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
    const blockPostEntity = new BlockPostEntity();
    const isExist = await this.blockPostRepository.findOne({
      where: {
        blocker: blockerId,
        blocked_post: postId,
      },
    });
    if (isExist !== null && isExist.status === true) {
      throw new HttpException('이미 차단 되었습니다.', 400);
    }
    blockPostEntity.blocked_post = postId;
    blockPostEntity.blocker = blockerId;
    blockPostEntity.status = true;
    await this.blockPostRepository.save(blockPostEntity);
  }

  async findBlockedPosts(blockerId: string) {
    const blockLists = await this.blockPostRepository.find({
      where: {
        blocker: blockerId,
        status: true,
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
}
