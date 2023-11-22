import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './createUser.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from 'src/entities/user.entity';
import { Repository } from 'typeorm';
import { S3Handler } from 'src/utils/S3Handler';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    private s3Handler: S3Handler,
  ) {}
  async createUser(imageLocation: string, createUserDto: CreateUserDto) {
    const userEntity = new UserEntity();
    userEntity.nickname = createUserDto.nickname;
    userEntity.social_email = createUserDto.social_email;
    userEntity.OAuth_domain = createUserDto.OAuth_domain;
    userEntity.profile_img = imageLocation;
    userEntity.user_hash = 'asdf';
    const res = await this.userRepository.save(userEntity);
    return res;
  }

  removeUser(id: number) {
    return `This action removes a #${id} user`;
  }

  async uploadImages(file: Express.Multer.File) {
    const fileLocation = await this.s3Handler.uploadFile(file);
    console.log(fileLocation);
    return fileLocation;
  }
}
