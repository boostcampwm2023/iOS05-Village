import {
  Body,
  Controller,
  Get,
  HttpException,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
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

  @Get('room')
  @UseGuards(AuthGuard)
  async roomList(@UserHash() userId: string) {
    return await this.chatService.findRoomList(userId);
  }

  @Get('room/:id')
  @UseGuards(AuthGuard)
  async roomDetail(@Param('id') id: number, @UserHash() userId: string) {
    return await this.chatService.findRoomById(id, userId);
  }

  // 게시글에서 채팅하기 버튼 누르면 채팅방 만드는 API (테스트는 안해봄, 좀더 수정 필요)
  @Post('room')
  @UseGuards(AuthGuard)
  async roomCreate(@Body() body: CreateRoomDto, @UserHash() userId: string) {
    const isUserPostExist = await this.chatService.isUserPostExist(
      body.post_id,
      body.writer,
    );
    if (!isUserPostExist) {
      throw new HttpException('해당 게시글 또는 유저가 없습니다', 404);
    }
    return await this.chatService.createRoom(body.post_id, userId, body.writer);
  }

  @Get('unread')
  @UseGuards(AuthGuard)
  async unreadChat(@UserHash() userId: string) {
    return await this.chatService.unreadChat(userId);
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
