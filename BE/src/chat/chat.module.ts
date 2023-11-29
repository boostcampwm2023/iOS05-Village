import { Module } from '@nestjs/common';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';
import { ChatsGateway } from './chats.gateway';

@Module({
  controllers: [ChatController],
  providers: [ChatService, ChatsGateway],
})
export class ChatModule {}
