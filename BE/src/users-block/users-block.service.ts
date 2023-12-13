import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { BlockUserEntity } from 'src/entities/blockUser.entity';
import { Repository } from 'typeorm';
import { UserEntity } from 'src/entities/user.entity';
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

    try {
      return await this.blockUserRepository.save(blockUserEntity);
    } catch (e) {
      throw new HttpException('서버 오류입니다', 500);
    }
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
