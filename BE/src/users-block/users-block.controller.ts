import { Controller, Get, Post, Body, Param, Delete } from '@nestjs/common';
import { UsersBlockService } from './users-block.service';

@Controller('users/block')
export class UsersBlockController {
  constructor(private readonly usersBlockService: UsersBlockService) {}

  @Get()
  async blockUserList() {
    const id = 'qwe';
    return this.usersBlockService.getBlockUser(id);
  }

  @Post('/:id')
  async blockUserAdd(@Param('id') id: string) {
    await this.usersBlockService.addBlockUser(id);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.usersBlockService.remove(+id);
  }
}
