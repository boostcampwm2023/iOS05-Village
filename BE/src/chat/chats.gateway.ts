import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Websocket } from 'ws';
import { ChatService } from './chat.service';
import { ChatDto } from './dto/chat.dto';
import { Logger } from '@nestjs/common';

@WebSocketGateway({
  path: 'chats',
})
export class ChatsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;
  private rooms = new Map<number, Set<Websocket>>();
  private readonly logger = new Logger('ChatsGateway');
  constructor(private readonly chatService: ChatService) {}
  handleConnection(client: Websocket) {
    this.logger.debug(`on connnect : ${client}`, 'ChatsGateway');
  }

  handleDisconnect(client: Websocket) {
    if (client.roomId) {
      const roomId = client.roomId;
      const room = this.rooms.get(roomId);
      room.delete(client);
      if (room.size === 0) {
        this.rooms.delete(roomId);
      }
    }
    this.logger.debug(
      `on disconnect : ${client}, left rooms : ${Array.from(
        this.rooms.keys(),
      )}`,
      'ChatsGateway',
    );
  }

  @SubscribeMessage('send-message')
  async sendMessage(
    @MessageBody() message: ChatDto,
    @ConnectedSocket() client: Websocket,
  ) {
    this.logger.debug(
      `[send message] room ID: ${message['room_id']} , sender: ${message['sender']}, message: ${message['message']}`,
    );
    const room = this.rooms.get(message['room_id']);
    const sender = message['sender'];
    await this.chatService.saveMessage(message);
    if (room.size === 1) {
      await this.chatService.sendPush(message);
    } else {
      room.forEach((people) => {
        if (people !== client)
          people.send(JSON.stringify({ sender, message: message['message'] }));
      });
    }
    client.send(JSON.stringify({ sent: true }));
  }

  @SubscribeMessage('join-room')
  joinRoom(
    @MessageBody() message: object,
    @ConnectedSocket() client: Websocket,
  ) {
    const roomId = message['room_id'];
    client.roomId = roomId;
    if (this.rooms.has(roomId)) this.rooms.get(roomId).add(client);
    else this.rooms.set(roomId, new Set([client]));
    this.logger.debug(`join room : ${roomId}`, 'ChatsGateway');
  }

  @SubscribeMessage('leave-room')
  leaveRoom(
    @MessageBody() message: object,
    @ConnectedSocket() client: Websocket,
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
