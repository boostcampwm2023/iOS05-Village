import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { BlockUserEntity } from 'src/entities/blockUser.entity';
import { Repository } from 'typeorm';
import { HttpException } from '@nestjs/common';
import { UserEntity } from 'src/entities/user.entity';

@Injectable()
export class UsersBlockService {
  constructor(
    @InjectRepository(BlockUserEntity)
    private blockUserRepository: Repository<BlockUserEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
  ) {}

  async addBlockUser(id: string) {
    const isExistUser = await this.userRepository.findOne({
      where: { user_hash: id },
    });

    if (!isExistUser) {
      throw new HttpException('존재하지 않는 유저입니다', 400);
    }

    const isBlockedUser = await this.blockUserRepository.findOne({
      where: { blocked_user: id, blocker: 'qwe' },
    });

    console.log(isBlockedUser);

    if (isBlockedUser) {
      throw new HttpException('이미 차단된 유저입니다', 400);
    }

    const blockUserEntity = new BlockUserEntity();
    blockUserEntity.blocker = 'qwe';
    blockUserEntity.blocked_user = id;
    blockUserEntity.status = 1;

    try {
      const res = await this.blockUserRepository.save(blockUserEntity);
      return res;
    } catch (e) {
      throw new HttpException('서버 오류입니다', 500);
    }
  }

  findAll() {
    return `This action returns all usersBlock`;
  }

  remove(id: number) {
    return `This action removes a #${id} usersBlock`;
  }
}
