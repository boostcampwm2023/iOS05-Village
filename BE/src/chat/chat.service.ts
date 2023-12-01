import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { In, Repository } from 'typeorm';
import { ChatRoomEntity } from '../entities/chatRoom.entity';
import { ChatEntity } from 'src/entities/chat.entity';
import { ChatDto } from './dto/chat.dto';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(ChatRoomEntity)
    private chatRoomRepository: Repository<ChatRoomEntity>,
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
    @InjectRepository(ChatEntity)
    private chatRepository: Repository<ChatEntity>,
  ) {}

  async saveMessage(message: ChatDto) {
    const chat = new ChatEntity();
    chat.sender = message.sender;
    chat.message = message.message;
    chat.chat_room = message.room_id;
    await this.chatRepository.save(chat);
  }

  async createRoom(postId: number, userId: string, writerId: string) {
    const chatRoom = new ChatRoomEntity();
    chatRoom.post_id = postId;
    chatRoom.writer = writerId;
    chatRoom.user = userId;
    const newChatRoom = await this.chatRoomRepository.save(chatRoom); // 없으면 새로 만들어서 저장후 리턴
    return newChatRoom;
  }

  async findRoomList(userId: string) {
    const rooms = await this.chatRoomRepository
      .createQueryBuilder('chat_room')
      .where('chat_room.writer = :writer', { writer: userId })
      .orWhere('chat_room.user = :user', { user: userId })
      .leftJoinAndSelect('chat_room.chats', 'chat')
      .orderBy('chat.id', 'DESC')
      .limit(1)
      .getMany();

    return rooms.reduce((acc, cur) => {
      acc.push({
        room_id: cur.id,
        post_id: cur.post_id,
        writer: cur.writer,
        user: cur.user,
        update_date: cur.update_date,
        last_chat: cur.chats[0].message,
      });
      return acc;
    }, []);
  }

  async findRoomById(roomId: number, userId: string) {
    const room = await this.chatRoomRepository.findOne({
      where: {
        id: roomId,
      },
      relations: ['chats'],
    });

    if (!room) {
      throw new HttpException('존재하지 않는 채팅방입니다.', 404);
    } else if (room.writer !== userId && room.user !== userId) {
      throw new HttpException('권한이 없습니다.', 403);
    }

    return {
      room_id: room.id,
      post_id: room.post_id,
      writer: room.writer,
      user: room.user,
      update_date: room.update_date,
      chats: room.chats,
    };
  }
}
