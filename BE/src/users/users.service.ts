import { HttpException, Inject, Injectable } from '@nestjs/common';
import { CreateUserDto } from './dto/createUser.dto';
import { UserEntity } from 'src/entities/user.entity';
import { hashMaker } from 'src/common/hashMaker';
import { ConfigService } from '@nestjs/config';
import * as jwt from 'jsonwebtoken';
import { CACHE_MANAGER, CacheStore } from '@nestjs/cache-manager';
import { UserRepository } from './user.repository';

@Injectable()
export class UsersService {
  constructor(
    private userRepository: UserRepository,
    @Inject(CACHE_MANAGER) private cacheManager: CacheStore,
    private configService: ConfigService,
  ) {}

  async createUser(imageLocation: string, createUserDto: CreateUserDto) {
    const userEntity = new UserEntity();
    userEntity.nickname = createUserDto.nickname;
    userEntity.social_id = createUserDto.social_email;
    userEntity.OAuth_domain = createUserDto.OAuth_domain;
    userEntity.profile_img = imageLocation;
    userEntity.user_hash = hashMaker(createUserDto.nickname).slice(0, 8);
    return await this.userRepository.getRepository(UserEntity).save(userEntity);
  }

  async findUserById(userId: string) {
    const user: UserEntity = await this.userRepository
      .getRepository(UserEntity)
      .findOne({
        where: { user_hash: userId },
      });
    if (user) {
      user.profile_img =
        user.profile_img ?? this.configService.get('DEFAULT_PROFILE_IMAGE');
      return { nickname: user.nickname, profile_img: user.profile_img };
    } else {
      return null;
    }
  }

  async removeUser(id: string, userId: string, accessToken: string) {
    const decodedToken: any = jwt.decode(accessToken);
    if (decodedToken && decodedToken.exp) {
      const ttl: number = decodedToken.exp - Math.floor(Date.now() / 1000);
      await this.cacheManager.set(accessToken, 'logout', { ttl });
    }
    await this.userRepository.softDeleteCascade(userId);
  }

  async checkAuth(id, userId) {
    const isDataExists = await this.userRepository
      .getRepository(UserEntity)
      .findOne({
        where: { user_hash: id },
      });
    if (!isDataExists) {
      throw new HttpException('유저가 존재하지 않습니다.', 404);
    }
    if (id !== userId) {
      throw new HttpException('수정 권한이 없습니다.', 403);
    }
  }

  async updateUserById(
    id: string,
    nickname: string,
    imageLocation: string,
    userId: string,
  ) {
    const user = new UserEntity();
    user.nickname = nickname ?? undefined;
    user.profile_img = imageLocation ?? undefined;

    await this.userRepository
      .getRepository(UserEntity)
      .update({ user_hash: userId }, user);
  }
}
