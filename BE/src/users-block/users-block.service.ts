import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { Repository } from 'typeorm';
import { UserEntity } from '../entities/user.entity';
import { ConfigService } from '@nestjs/config';

interface BlockedUser {
  user_id: string;
  nickname?: string;
  profile_img?: string;
}

@Injectable()
export class UsersBlockService {
  constructor(
    @InjectRepository(BlockUserEntity)
    private blockUserRepository: Repository<BlockUserEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    private configService: ConfigService,
  ) {}

  async addBlockUser(id: string, userId: string) {
    const isExistUser = await this.userRepository.findOne({
      where: { user_hash: id },
      withDeleted: true,
    });

    if (!isExistUser) {
      throw new HttpException('존재하지 않는 유저입니다', 404);
    }

    const isBlockedUser = await this.blockUserRepository.findOne({
      where: { blocked_user: id, blocker: userId },
      withDeleted: true,
    });

    if (isBlockedUser !== null && isBlockedUser.delete_date === null) {
      throw new HttpException('이미 차단된 유저입니다', 400);
    }
    const blockUserEntity = new BlockUserEntity();
    blockUserEntity.blocker = userId;
    blockUserEntity.blocked_user = id;
    blockUserEntity.delete_date = null;
    return await this.blockUserRepository.save(blockUserEntity);
  }

  async checkBlockUser(oppId: string, userId: string) {
    const isExistUser = await this.userRepository.findOne({
      where: { user_hash: oppId },
      withDeleted: true,
    });

    if (!isExistUser) {
      throw new HttpException('존재하지 않는 유저입니다', 404);
    }

    const checkBlock = await this.blockUserRepository.findOne({
      where: { blocker: userId, blocked_user: oppId },
      withDeleted: true,
    });

    if (checkBlock !== null) {
      return { block: 'block' };
    }

    const checkBlocked = await this.blockUserRepository.findOne({
      where: { blocker: oppId, blocked_user: userId },
      withDeleted: true,
    });

    if (checkBlocked !== null) {
      return { block: 'blocked' };
    }

    return { block: 'none' };
  }

  async getBlockUser(id: string) {
    const res = await this.blockUserRepository.find({
      where: { blocker: id },
      relations: ['blockedUser'],
    });

    const blockedUsers = res.reduce((acc, cur) => {
      const user: BlockedUser = {
        user_id: cur.blocked_user,
      };
      if (cur.blockedUser === null) {
        user.nickname = null;
        user.profile_img = null;
      } else {
        user.nickname = cur.blockedUser.nickname;
        user.profile_img =
          cur.blockedUser.profile_img === null
            ? this.configService.get('DEFAULT_PROFILE_IMAGE')
            : cur.blockedUser.profile_img;
      }
      acc.push(user);
      return acc;
    }, []);

    return blockedUsers;
  }

  async removeBlockUser(blockedUserId: string, userId: string) {
    const blockedUser = await this.blockUserRepository.findOne({
      where: { blocked_user: blockedUserId, blocker: userId },
    });
    if (!blockedUser) {
      throw new HttpException('없는 사용자 입니다.', 404);
    }
    await this.blockUserRepository.softDelete({
      blocked_user: blockedUserId,
      blocker: userId,
    });
  }
}
