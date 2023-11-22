import { Injectable } from '@nestjs/common';
import { CreateUserDto } from './createUser.dto';

@Injectable()
export class UsersService {
  createUser(createUserDto: CreateUserDto) {
    return 'This action adds a new user';
  }

  removeUser(id: number) {
    return `This action removes a #${id} user`;
  }
}
