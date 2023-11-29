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

  async createOrFindRoom(postId: number, userId: string, writerId: string) {
    const roomNumber = await this.chatRoomRepository.findOne({
      where: { writer: writerId, user: userId, post_id: postId },
    }); // 해당 게시글과 사람들에 대한 채팅방이 있는지 확인한다

    if (roomNumber) {
      return roomNumber; // 있으면 채팅방 번호 리턴
    } else {
      const chatRoom = new ChatRoomEntity();
      chatRoom.post_id = postId;
      chatRoom.writer = writerId;
      chatRoom.user = userId;
      const newChatRoom = await this.chatRoomRepository.save(chatRoom); // 없으면 새로 만들어서 저장후 리턴
      return newChatRoom;
    }

    //이후에 채팅과 Join 해서 채팅 목록도 가져와야함
  }
}
