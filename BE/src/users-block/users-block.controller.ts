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
import { UserHash } from 'src/utils/auth.decorator';

@Controller('users/block')
@UseGuards(AuthGuard)
export class UsersBlockController {
  constructor(private readonly usersBlockService: UsersBlockService) {}

  @Get()
  async blockUserList(@UserHash() userId: string) {
    return this.usersBlockService.getBlockUser(userId);
  }

  @Post('/:id')
  async blockUserAdd(@Param('id') id: string, @UserHash() userId: string) {
    await this.usersBlockService.addBlockUser(id, userId);
  }

  @Delete(':id')
  async blockUserRemove(@Param('id') id: string, @UserHash() userId: string) {
    await this.usersBlockService.removeBlockUser(id, userId);
  }
}
