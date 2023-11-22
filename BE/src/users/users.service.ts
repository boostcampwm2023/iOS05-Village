import { HttpException, Injectable } from '@nestjs/common';
import { CreateUserDto } from './createUser.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from '../entities/user.entity';
import { Repository } from 'typeorm';
import { UpdatePostDto } from '../post/dto/postUpdate.dto';
import { UpdateUsersDto } from './usersUpdate.dto';
import { S3Handler } from '../utils/S3Handler';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    private s3Handler: S3Handler,
  ) {}
  async findUserById(userId: string) {
    const user: UserEntity = await this.userRepository.findOne({
      where: { user_hash: userId, status: true },
    });
    if (user) {
      return { nickname: user.nickname, profile_img: user.profile_img };
    } else {
      return null;
    }
  }
  createUser(createUserDto: CreateUserDto) {
    return 'This action adds a new user';
  }

  removeUser(id: number) {
    return `This action removes a #${id} user`;
  }

  async updateUserById(
    userId: string,
    body: UpdateUsersDto,
    file: Express.Multer.File,
  ) {
    const isDataExists = await this.userRepository.findOne({
      where: { user_hash: userId },
    });
    const isChangingImage = file !== undefined;
    const isChangingBody = body !== undefined;

    if (!isDataExists) {
      throw new HttpException('유저가 존재하지 않습니다.', 404);
    } else if (!isChangingImage && isChangingBody) {
      await this.changeExceptImages(userId, body);
    } else if (!isChangingBody && !isChangingImage) {
      throw new HttpException('수정 할 것이 없는데 요청을 보냈습니다.', 400);
    } else if (!isChangingBody && isChangingImage) {
      await this.changeImages(userId, file);
    } else {
      await this.changeExceptImages(userId, body);
      await this.changeImages(userId, file);
    }
  }

  async changeExceptImages(userId: string, body: UpdateUsersDto) {
    try {
      await this.userRepository.update({ user_hash: userId }, body);
    } catch (e) {
      throw new HttpException('서버 오류입니다. db', 500);
    }
  }

  async changeImages(userId: string, file: Express.Multer.File) {
    try {
      if (file === null) {
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
      throw new HttpException('서버 오류입니다. ima', 500);
    }
  }
}
