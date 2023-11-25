import { Controller, Get, Post, Param, Delete } from '@nestjs/common';
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
    const userId = 'qwe';
    await this.usersBlockService.addBlockUser(id, userId);
  }

  @Delete(':id')
  async blockUserRemove(@Param('id') id: string) {
    const userId = 'qwe';
    await this.usersBlockService.removeBlockUser(id, userId);
  }
}
