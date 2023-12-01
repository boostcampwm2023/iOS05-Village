import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { ChatService } from './chat.service';
import { AuthGuard } from '../utils/auth.guard';
import { UserHash } from '../utils/auth.decorator';
import { CreateRoomDto } from './createRoom.dto';

@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('room')
  @UseGuards(AuthGuard)
  async roomDetail(@Param('id') id: string, @UserHash() userId: string) {
    return await this.chatService.findRoomList(userId);
  }

  // 게시글에서 채팅하기 버튼 누르면 채팅방 만드는 API (테스트는 안해봄, 좀더 수정 필요)
  @Post('room')
  @UseGuards(AuthGuard)
  async roomCreate(@Body() body: CreateRoomDto, @UserHash() userId: string) {
    await this.chatService.createRoom(body.post_id, userId, body.writer);
  }
}
