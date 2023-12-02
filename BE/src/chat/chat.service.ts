import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { Repository } from 'typeorm';
import { ChatRoomEntity } from '../entities/chatRoom.entity';
import { ChatEntity } from 'src/entities/chat.entity';
import { ChatDto } from './dto/chat.dto';
import { UserEntity } from 'src/entities/user.entity';

@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(ChatRoomEntity)
    private chatRoomRepository: Repository<ChatRoomEntity>,
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
    @InjectRepository(ChatEntity)
    private chatRepository: Repository<ChatEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
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
      .select([
        'chat_room.user',
        'chat_room.writer',
        'chat_room.id',
        'chat_room.post_id',
        'chat.message',
      ])
      .where('chat_room.user = :userId', {
        userId: userId,
      })
      .orWhere('chat_room.writer = :userId', {
        userId: userId,
      })
      .select([
        'chat_room.user',
        'chat_room.writer',
        'chat_room.id',
        'chat_room.post_id',
        'chat.message',
      ])
      .innerJoin('chat', 'chat', 'chat_room.id = chat.chat_room')
      .orderBy('chat.id', 'DESC')
      .limit(1)
      .addSelect(['user.w.user_hash', 'user.w.profile_img'])
      .leftJoin('user', 'user.w', 'user.w.user_hash = chat_room.writer')
      .addSelect(['user.u.user_hash', 'user.u.profile_img'])
      .leftJoin('user', 'user.u', 'user.u.user_hash = chat_room.user')
      .getRawMany();

    return rooms.reduce((acc, cur) => {
      acc.push({
        room_id: cur.chat_room_id,
        post_id: cur.chat_room_post_id,
        user: cur['user.w_user_hash'],
        user_profile_img: cur['user.w_profile_img'],
        writer: cur['user.u_user_hash'],
        writer_profile_img: cur['user.u_profile_img'],
        last_chat: cur.chat_message,
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
      chatLog: room.chats,
    };
  }
}
