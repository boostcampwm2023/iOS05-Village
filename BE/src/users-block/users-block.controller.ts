import {
  Controller,
  Get,
  Post,
  Param,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { UsersBlockService } from './users-block.service';
import { AuthGuard } from 'src/utils/auth.guard';

@Controller('users/block')
@UseGuards(AuthGuard)
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
