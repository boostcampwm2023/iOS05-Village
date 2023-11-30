import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import { ChatService } from './chat.service';
import { AuthGuard } from '../utils/auth.guard';
import { UserHash } from '../utils/auth.decorator';
import { CreateRoomDto } from './createRoom.dto';
import { FcmHandler } from '../utils/fcmHandler';

@Controller('chat')
export class ChatController {
  constructor(
    private readonly chatService: ChatService,
    private readonly fcmHandler: FcmHandler,
  ) {}

  // 게시글에서 채팅하기 버튼 누르면 채팅방 만드는 API (테스트는 안해봄, 좀더 수정 필요)
  @Post('room')
  @UseGuards(AuthGuard)
  async roomCreate(@Body() body: CreateRoomDto, @UserHash() userId: string) {
    console.log(userId);
    await this.chatService.createOrFindRoom(body.post_id, userId, body.writer);
  }

  @Get()
  async testPush(@Body() body) {
    await this.fcmHandler.sendPush(body.user, {
      title: 'test',
      body: 'hello!',
      data: { room_id: body.room },
    });
  }
}
