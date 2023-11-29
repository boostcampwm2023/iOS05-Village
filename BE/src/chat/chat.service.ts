import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { Repository } from 'typeorm';
import { ChatRoomEntity } from '../entities/chatRoom.entity';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(ChatRoomEntity)
    private chatRoomRepository: Repository<ChatRoomEntity>,
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
  ) {}
  async createRoom(postId: number, userId: string, writerId: string) {
    const chatRoom = new ChatRoomEntity();
    chatRoom.post_id = postId;
    chatRoom.writer = writerId;
    chatRoom.sender = userId;
    const newChatRoom = await this.chatRoomRepository.save(chatRoom);
    // 좀 더 가공해서 채팅 룸에 대한 정보 줄 수 있게 수정하면 될듯
    return newChatRoom;
  }
}
