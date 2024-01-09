import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ChatRoomEntity } from '../entities/chatRoom.entity';
import { ChatEntity } from 'src/entities/chat.entity';
import { ChatDto } from './dto/chat.dto';
import { UserEntity } from 'src/entities/user.entity';
import { FcmHandler, PushMessage } from '../common/fcmHandler';
import * as jwt from 'jsonwebtoken';
import { ConfigService } from '@nestjs/config';
import { JwtPayload } from 'jsonwebtoken';
import { PostEntity } from '../entities/post.entity';

export interface ChatRoom {
  room_id: number;
}
interface Payload extends JwtPayload {
  userId: string;
  nickname: string;
}
@Injectable()
export class ChatService {
  constructor(
    @InjectRepository(ChatRoomEntity)
    private chatRoomRepository: Repository<ChatRoomEntity>,
    @InjectRepository(ChatEntity)
    private chatRepository: Repository<ChatEntity>,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
    private fcmHandler: FcmHandler,
    private configService: ConfigService,
  ) {}

  async saveMessage(message: ChatDto, is_read: boolean) {
    const chat = new ChatEntity();
    chat.sender = message.sender;
    chat.message = message.message;
    chat.chat_room = message.room_id;
    chat.is_read = is_read;
    chat.count = message.count;
    await this.chatRepository.save(chat);
  }

  async createRoom(
    postId: number,
    userId: string,
    writerId: string,
  ): Promise<ChatRoom> {
    if (userId === writerId) {
      throw new HttpException('자신과는 채팅할 수 없습니다.', 400);
    }
    const isExist = await this.chatRoomRepository.findOne({
      where: { post_id: postId, user: userId, writer: writerId },
    });
    if (isExist) {
      return { room_id: isExist.id };
    }
    const chatRoom = new ChatRoomEntity();
    chatRoom.post_id = postId;
    chatRoom.writer = writerId;
    chatRoom.user = userId;

    const roomId = (await this.chatRoomRepository.save(chatRoom)).id;
    return { room_id: roomId };
  }

  async isUserPostExist(postId: number, writerId: string) {
    const isUserExist = await this.userRepository.exist({
      where: { user_hash: writerId },
    });
    const isPostExist = await this.postRepository.exist({
      where: { id: postId },
    });
    return isPostExist && isUserExist;
  }

  async findRoomList(userId: string) {
    const chatListInfo = { all_read: true, chat_list: [] };

    const subquery = this.chatRepository
      .createQueryBuilder('chat')
      .select('chat.id', 'id')
      .addSelect('chat.chat_room', 'chat_room')
      .addSelect('chat.message', 'message')
      .addSelect('chat.create_date', 'create_date')
      .addSelect('chat.is_read', 'is_read')
      .addSelect('chat.sender', 'sender')
      .where(
        'chat.id IN (SELECT MAX(chat.id) FROM chat GROUP BY chat.chat_room)',
      );

    const rooms = await this.chatRoomRepository
      .createQueryBuilder('chat_room')
      .innerJoin(
        '(' + subquery.getQuery() + ')',
        'chat_info',
        'chat_room.id = chat_info.chat_room',
      )
      .innerJoin(
        'chat_room.writerUser',
        'writer',
        'chat_room.writerUser = writer.user_hash',
      )
      .innerJoin(
        'chat_room.userUser',
        'user',
        'chat_room.userUser = user.user_hash',
      )
      .leftJoin('chat_room.post', 'post', 'chat_room.post = post.id')
      .select([
        'chat_room.id as room_id',
        'chat_room.writer as writer',
        'writer.nickname as writer_nickname',
        'writer.profile_img as writer_profile_img',
        'chat_room.user as user',
        'user.nickname as user_nickname',
        'user.profile_img as user_profile_img',
        'chat_room.post_id as post_id',
        'post.title as post_title',
        'post.thumbnail as post_thumbnail',
        'chat_info.create_date as last_chat_date',
        'chat_info.message as last_chat',
        'chat_info.is_read as all_read',
        'chat_info.sender as sender',
      ])
      .where('chat_room.writer = :userId', { userId: userId })
      .andWhere('chat_room.writer_left IS false')
      .orWhere('chat_room.user = :userId', { userId: userId })
      .andWhere('chat_room.user_left IS false')
      .orderBy('chat_info.create_date', 'DESC')
      .getRawMany();

    chatListInfo.chat_list = rooms.reduce((acc, cur) => {
      cur.writer_profile_img =
        cur.writer_profile_img === null
          ? this.configService.get('DEFAULT_PROFILE_IMAGE')
          : cur.writer_profile_img;

      cur.user_profile_img =
        cur.user_profile_img === null
          ? this.configService.get('DEFAULT_PROFILE_IMAGE')
          : cur.user_profile_img;

      if (cur.sender === userId) {
        cur.all_read = true;
      } else {
        if (cur.all_read === 0) {
          chatListInfo.all_read = false;
          cur.all_read = false;
        } else {
          cur.all_read = true;
        }
      }
      delete cur.sender;
      acc.push(cur);
      return acc;
    }, []);

    return chatListInfo;
  }

  async unreadChat(userId: string) {
    const subquery = this.chatRepository
      .createQueryBuilder('chat')
      .select('chat.id', 'id')
      .addSelect('chat.chat_room', 'chat_room')
      .addSelect('chat.message', 'message')
      .addSelect('chat.create_date', 'create_date')
      .addSelect('chat.is_read', 'is_read')
      .addSelect('chat.sender', 'sender')
      .where(
        'chat.id IN (SELECT MAX(chat.id) FROM chat GROUP BY chat.chat_room)',
      );

    const rooms = await this.chatRoomRepository
      .createQueryBuilder('chat_room')
      .innerJoin(
        '(' + subquery.getQuery() + ')',
        'chat_info',
        'chat_room.id = chat_info.chat_room',
      )
      .innerJoin(
        'chat_room.writerUser',
        'writer',
        'chat_room.writerUser = writer.user_hash',
      )
      .innerJoin(
        'chat_room.userUser',
        'user',
        'chat_room.userUser = user.user_hash',
      )
      .select([
        'chat_room.id as room_id',
        'chat_room.writer as writer',
        'writer.nickname as writer_nickname',
        'writer.profile_img as writer_profile_img',
        'chat_room.user as user',
        'user.nickname as user_nickname',
        'user.profile_img as user_profile_img',
        'chat_room.post_id as post_id',
        'chat_info.create_date as last_chat_date',
        'chat_info.message as last_chat',
        'chat_info.is_read as is_read',
        'chat_info.sender as sender',
      ])
      .where('chat_room.writer = :userId', { userId: userId })
      .andWhere('chat_room.writer_left IS false')
      .orWhere('chat_room.user = :userId', { userId: userId })
      .andWhere('chat_room.user_left IS false')
      .orderBy('chat_info.create_date', 'DESC')
      .getRawMany();

    for (const room of rooms) {
      if (room.sender !== userId && room.is_read === 0) {
        return { all_read: false };
      }
    }

    return { all_read: true };
  }

  async findRoomById(roomId: number, userId: string) {
    await this.chatRepository
      .createQueryBuilder('chat')
      .update()
      .set({ is_read: true })
      .where('chat.chat_room = :roomId', { roomId: roomId })
      .andWhere('chat.is_read = :isRead', { isRead: false })
      .andWhere('chat.sender != :userId', { userId: userId })
      .execute();

    const room = await this.chatRoomRepository.findOne({
      where: {
        id: roomId,
      },
      relations: ['chats', 'userUser', 'writerUser'],
    });

    this.checkAuth(room, userId);
    return {
      writer: room.writer,
      writer_profile_img:
        room.writerUser.profile_img === null
          ? this.configService.get('DEFAULT_PROFILE_IMAGE')
          : room.writerUser.profile_img,
      user: room.user,
      user_profile_img:
        room.userUser.profile_img === null
          ? this.configService.get('DEFAULT_PROFILE_IMAGE')
          : room.userUser.profile_img,
      post_id: room.post_id,
      chat_log: room.chats,
    };
  }

  checkAuth(room: ChatRoomEntity, userId: string) {
    if (!room) {
      throw new HttpException('존재하지 않는 채팅방입니다.', 404);
    } else if (room.writer !== userId && room.user !== userId) {
      throw new HttpException('권한이 없습니다.', 403);
    }
  }

  async sendPush(message: ChatDto) {
    const chatRoom = await this.chatRoomRepository.findOne({
      where: { id: message.room_id },
      relations: ['writerUser', 'userUser'],
    });

    const receiver: UserEntity =
      chatRoom.writerUser.user_hash === message.sender
        ? chatRoom.userUser
        : chatRoom.writerUser;
    const sender: UserEntity =
      chatRoom.writerUser.user_hash !== message.sender
        ? chatRoom.userUser
        : chatRoom.writerUser;
    const pushMessage: PushMessage = this.fcmHandler.createChatPushMessage(
      sender.nickname,
      message.message,
      message.room_id,
    );
    await this.fcmHandler.sendPush(receiver.user_hash, pushMessage);
  }

  async checkOpponentLeft(roomId: number, userId: string) {
    const room = await this.chatRoomRepository.findOne({
      where: { id: roomId },
    });

    if (room.writer === userId && room.user_left !== false) {
      room.user_left = false;
    } else if (room.user === userId && room.writer_left !== false) {
      room.writer_left = false;
    }
    await this.chatRoomRepository.save(room);
  }

  validateUser(authorization) {
    try {
      const payload: Payload = jwt.verify(
        authorization.split(' ')[1],
        this.configService.get('JWT_SECRET'),
      ) as Payload;
      console.log(payload.userId);
      return payload.userId;
    } catch {
      return null;
    }
  }
}
