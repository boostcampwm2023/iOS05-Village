import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, WebSocket } from 'ws';
import { ChatService } from './chat.service';
import { ChatDto } from './dto/chat.dto';
import { Logger } from '@nestjs/common';

interface ChatWebSocket extends WebSocket {
  roomId: number;
  userId: string;
}
@WebSocketGateway({
  path: 'chats',
})
export class ChatsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;
  private rooms = new Map<number, Set<ChatWebSocket>>();
  private readonly logger = new Logger('ChatsGateway');
  constructor(private readonly chatService: ChatService) {}
  handleConnection(client: ChatWebSocket, ...args) {
    const { authorization } = args[0].headers;
    const userId = this.chatService.validateUser(authorization);
    if (userId === null) {
      client.close(1008, '토큰이 유효하지 않습니다.');
    }
    client.userId = userId;
    this.logger.debug(`[${userId}] on connect`, 'ChatsGateway');
    this.logger.debug(`[] on connect`, 'ChatsGateway');
  }

  handleDisconnect(client: ChatWebSocket) {
    if (client.roomId) {
      const roomId = client.roomId;
      const room = this.rooms.get(roomId);
      room.delete(client);
      if (room.size === 0) {
        this.rooms.delete(roomId);
      }
    }
    this.logger.debug(
      `[${client.userId}] on disconnect => left rooms : ${Array.from(
        this.rooms.keys(),
      )}`,
      'ChatsGateway',
    );
  }

  @SubscribeMessage('send-message')
  async sendMessage(
    @MessageBody() message: ChatDto,
    @ConnectedSocket() client: ChatWebSocket,
  ) {
    this.logger.debug(
      `[${client.userId}] send message { room ID: ${message['room_id']} , sender: ${message['sender']}, message: ${message['message']} }`,
    );
    const room = this.rooms.get(message['room_id']);
    const sender = message['sender'];
    if (room.size === 1) {
      await this.chatService.saveMessage(message, false);
      await this.chatService.sendPush(message);
    } else {
      await this.chatService.saveMessage(message, true);
      room.forEach((people) => {
        if (people !== client)
          people.send(
            JSON.stringify({
              event: 'send-message',
              data: {
                sender: sender,
                message: message['message'],
                is_read: true,
                count: message['count'],
              },
            }),
          );
      });
    }
    client.send(
      JSON.stringify({ event: 'send-message', data: { sent: true } }),
    );
  }

  @SubscribeMessage('join-room')
  joinRoom(
    @MessageBody() message: object,
    @ConnectedSocket() client: ChatWebSocket,
  ) {
    const roomId = message['room_id'];
    client.roomId = roomId;
    if (this.rooms.has(roomId)) {
      this.rooms.get(roomId).add(client);

      const room = this.rooms.get(roomId);

      room.forEach((people) => {
        if (people !== client)
          people.send(
            JSON.stringify({
              event: 'join-room',
              data: { 'opp-entered': true },
            }),
          );
      });
    } else this.rooms.set(roomId, new Set([client]));
    this.logger.debug(
      `[${client.userId}] join room : ${roomId}`,
      'ChatsGateway',
    );
  }

  @SubscribeMessage('leave-room')
  leaveRoom(
    @MessageBody() message: object,
    @ConnectedSocket() client: ChatWebSocket,
  ) {
    const roomId = message['room_id'];
    const room = this.rooms.get(roomId);
    room.delete(client);
    if (room.size === 0) {
      this.rooms.delete(roomId);
    }
    console.log(this.rooms);
  }
}
