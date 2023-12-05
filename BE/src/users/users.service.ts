import { HttpException, Injectable } from '@nestjs/common';
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

@Injectable()
export class UsersService {
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
    @InjectRepository(RegistrationTokenEntity)
    private registrationTokenRepository: Repository<RegistrationTokenEntity>,
    private s3Handler: S3Handler,
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
      return { nickname: user.nickname, profile_img: user.profile_img };
    } else {
      return null;
    }
  }

  async removeUser(id: string, userId) {
    const userPk = await this.checkAuth(id, userId);
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
    if (body === undefined) {
      throw new HttpException('수정 할 것이 없는데 요청을 보냈습니다.', 400);
    }
    await this.checkAuth(id, userId);

    const nickname = body.nickname;
    const isImageChanged = body.is_image_changed;
    if (nickname) {
      await this.changeNickname(id, nickname);
    }
    if (isImageChanged !== undefined) {
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
      if (file === undefined) {
        await this.userRepository.update(
          { user_hash: userId },
          { profile_img: null },
        );
      } else {
        const fileLocation = await this.s3Handler.uploadFile(file);
        await this.userRepository.update(
          { user_hash: userId },
          { profile_img: fileLocation },
        );
      }
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
