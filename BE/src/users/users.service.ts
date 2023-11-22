import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './createUser.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from '../entities/user.entity';
import { Repository } from 'typeorm';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
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
}
