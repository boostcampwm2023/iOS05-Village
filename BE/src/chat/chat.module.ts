import { Module } from '@nestjs/common';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';
import { ChatsGateway } from './chats.gateway';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ChatRoomEntity } from '../entities/chatRoom.entity';
import { PostEntity } from '../entities/post.entity';
import { FcmHandler } from '../utils/fcmHandler';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ChatRoomEntity,
      PostEntity,
      RegistrationTokenEntity,
    ]),
  ],
  controllers: [ChatController],
  providers: [ChatService, ChatsGateway, FcmHandler],
})
export class ChatModule {}
