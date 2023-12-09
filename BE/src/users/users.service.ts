import { HttpException, Inject, Injectable } from '@nestjs/common';
import { CreateUserDto } from './createUser.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from 'src/entities/user.entity';
import { Repository } from 'typeorm';
import { UpdateUsersDto } from './usersUpdate.dto';
import { S3Handler } from '../utils/S3Handler';
import { hashMaker } from 'src/utils/hashMaker';
import { PostEntity } from '../entities/post.entity';
import { PostImageEntity } from '../entities/postImage.entity';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';
import { ConfigService } from '@nestjs/config';
import * as jwt from 'jsonwebtoken';
import { FcmHandler } from 'src/utils/fcmHandler';
import { CACHE_MANAGER, CacheStore } from '@nestjs/cache-manager';

@Injectable()
export class UsersService {
  constructor(
    @Inject(CACHE_MANAGER) private cacheManager: CacheStore,
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
    @InjectRepository(RegistrationTokenEntity)
    private registrationTokenRepository: Repository<RegistrationTokenEntity>,
    private s3Handler: S3Handler,
    private configService: ConfigService,
    private fcmHandler: FcmHandler,
  ) {}

  async createUser(imageLocation: string, createUserDto: CreateUserDto) {
    const userEntity = new UserEntity();
    userEntity.nickname = createUserDto.nickname;
    userEntity.social_id = createUserDto.social_email;
    userEntity.OAuth_domain = createUserDto.OAuth_domain;
    userEntity.profile_img = imageLocation;
    userEntity.user_hash = hashMaker(createUserDto.nickname).slice(0, 8);
    const res = await this.userRepository.save(userEntity);
    return res;
  }

  async findUserById(userId: string) {
    const user: UserEntity = await this.userRepository.findOne({
      where: { user_hash: userId },
    });
    if (user) {
      if (user.profile_img === null) {
        user.profile_img = this.configService.get('DEFAULT_PROFILE_IMAGE');
      }
      return { nickname: user.nickname, profile_img: user.profile_img };
    } else {
      return null;
    }
  }

  async removeUser(id: string, userId: string, accessToken: string) {
    const userPk = await this.checkAuth(id, userId);
    const decodedToken: any = jwt.decode(accessToken);
    if (decodedToken && decodedToken.exp) {
      await this.fcmHandler.removeRegistrationToken(decodedToken.userId);
      const ttl: number = decodedToken.exp - Math.floor(Date.now() / 1000);
      await this.cacheManager.set(accessToken, 'logout', { ttl });
    }

    await this.deleteCascadingUser(userPk, userId);
    return true;
  }

  async deleteCascadingUser(userId, userHash) {
    const postsByUser = await this.postRepository.find({
      where: { user_hash: userHash },
    });
    for (const postByUser of postsByUser) {
      await this.deleteCascadingPost(postByUser.id);
    }
    await this.blockPostRepository.softDelete({ blocker: userHash });
    await this.blockUserRepository.softDelete({ blocker: userHash });
    await this.userRepository.softDelete({ id: userId });
  }

  async deleteCascadingPost(postId: number) {
    await this.postImageRepository.softDelete({ post_id: postId });
    await this.blockPostRepository.softDelete({ blocked_post: postId });
    await this.postRepository.softDelete({ id: postId });
  }

  async checkAuth(id, userId) {
    const isDataExists = await this.userRepository.findOne({
      where: { user_hash: id },
    });
    if (!isDataExists) {
      throw new HttpException('유저가 존재하지 않습니다.', 404);
    }
    if (id !== userId) {
      throw new HttpException('수정 권한이 없습니다.', 403);
    }
    return isDataExists.id;
  }

  async updateUserById(
    id: string,
    body: UpdateUsersDto,
    file: Express.Multer.File,
    userId: string,
  ) {
    await this.checkAuth(id, userId);
    if (body) {
      await this.changeNickname(id, body.nickname);
    }
    if (file !== undefined) {
      await this.changeImages(id, file);
    }
  }

  async changeNickname(userId: string, nickname: string) {
    try {
      await this.userRepository.update(
        { user_hash: userId },
        { nickname: nickname },
      );
    } catch (e) {
      throw new HttpException('서버 오류입니다.', 500);
    }
  }

  async changeImages(userId: string, file: Express.Multer.File) {
    try {
      const fileLocation = await this.s3Handler.uploadFile(file);
      await this.userRepository.update(
        { user_hash: userId },
        { profile_img: fileLocation },
      );
    } catch (e) {
      throw new HttpException('서버 오류입니다.', 500);
    }
  }

  async uploadImages(file: Express.Multer.File) {
    const fileLocation = await this.s3Handler.uploadFile(file);
    return fileLocation;
  }

  async registerToken(userId, registrationToken) {
    const registrationTokenEntity =
      await this.registrationTokenRepository.findOne({
        where: { user_hash: userId },
      });
    if (registrationTokenEntity === null) {
      await this.registrationTokenRepository.save({
        user_hash: userId,
        registration_token: registrationToken,
      });
    } else {
      await this.updateRegistrationToken(userId, registrationToken);
    }
  }

  async updateRegistrationToken(userId, registrationToken) {
    const registrationTokenEntity = new RegistrationTokenEntity();
    registrationTokenEntity.registration_token = registrationToken;
    await this.registrationTokenRepository.update(
      {
        user_hash: userId,
      },
      registrationTokenEntity,
    );
  }
}
