import { DataSource } from 'typeorm';
import { PostEntity } from '../entities/post.entity';
import { Inject, Injectable, Scope } from '@nestjs/common';
import { PostListDto } from './dto/postList.dto';
import { BaseRepository } from '../common/base.repository';
import { REQUEST } from '@nestjs/core';

@Injectable({ scope: Scope.REQUEST })
export class PostRepository extends BaseRepository {
  constructor(dataSource: DataSource, @Inject(REQUEST) req: Request) {
    super(dataSource, req);
  }

  async findExceptBlock(
    blocker: string,
    options: PostListDto,
  ): Promise<Array<PostEntity>> {
    const limit = 20;
    return await this.getRepository(PostEntity)
      .createQueryBuilder('post')
      .leftJoin(
        'post.blocked_posts',
        'bp',
        'bp.blocker = :blocker AND bp.blocked_post = post.id',
        { blocker: blocker },
      )
      .leftJoin(
        'post.blocked_users',
        'bu',
        'bu.blocker = :blocker AND bu.blocked_user = post.user_hash',
      )
      .where('bp.blocked_post IS NULL')
      .andWhere('bu.blocked_user IS NULL')
      .andWhere(this.createOption(options))
      .orderBy('post.id', 'DESC')
      .limit(limit)
      .getMany();
  }

  async findOneWithBlock(blocker: string, postId: number) {
    return await this.getRepository(PostEntity)
      .createQueryBuilder('post')
      .leftJoinAndSelect(
        'post.blocked_posts',
        'bp',
        'bp.blocker = :blocker AND bp.blocked_post = post.id',
        { blocker: blocker },
      )
      .leftJoinAndSelect(
        'post.blocked_users',
        'bu',
        'bu.blocker = :blocker AND bu.blocked_user = post.user_hash',
      )
      .leftJoinAndSelect('post.post_images', 'pi', 'pi.post_id = post.id')
      .where('post.id = :postId', { postId: postId })
      .getOne();
  }

  async softDeleteCascade(postId: number) {
    const post = await this.getRepository(PostEntity).findOne({
      where: { id: postId },
      relations: ['blocked_posts', 'post_images'],
    });
    await this.getRepository(PostEntity).softRemove(post);
  }

  createOption(options: PostListDto) {
    let option =
      options.cursorId === undefined
        ? 'post.id > -1 AND '
        : `post.id < ${options.cursorId} AND `;
    if (options.requestFilter !== undefined) {
      option += `post.is_request = ${options.requestFilter} AND `;
    }
    if (options.writer !== undefined) {
      option += `post.user_hash = '${options.writer}' AND `;
    }
    if (options.searchKeyword !== undefined) {
      option += `post.title LIKE '%${options.searchKeyword}%' AND `;
    }
    return option.replace(/\s*AND\s*$/, '').trim();
  }
}
