import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Websocket } from 'ws';
import { ChatService } from './chat.service';

@WebSocketGateway({
  path: 'chats',
})
export class ChatsGateway implements OnGatewayConnection {
  @WebSocketServer() server: Server;
  private rooms = new Map<string, Set<Websocket>>();

  constructor(private readonly chatService: ChatService) {}
  handleConnection(client: Websocket) {
    // 인증 로직
    console.log(`on connnect : ${client}`);
  }

  handleDisconnect(client: Websocket) {
    console.log(`on disconnect : ${client}`);
  }

  @SubscribeMessage('send-message')
  sendMessage(
    @MessageBody() message: object,
    @ConnectedSocket() client: Websocket,
  ) {
    console.log(message);
    const room = this.rooms.get(message['room']);
    const sender = message['sender'];
    room.forEach((people) => {
      if (people !== client)
        people.send(JSON.stringify({ sender, message: message['message'] }));
    });
  }

  @SubscribeMessage('join-room')
  joinRoom(
    @MessageBody() message: object,
    @ConnectedSocket() client: Websocket,
  ) {
    console.log("join", message);
    const roomName = message['room'];
    if (this.rooms.has(roomName)) this.rooms.get(roomName).add(client);
    else this.rooms.set(roomName, new Set([client]));
    console.log(this.rooms)
  }

  @SubscribeMessage('leave-room')
  leaveRoom(
    @MessageBody() message: object,
    @ConnectedSocket() client: Websocket,
  ) {
    const roomName = message['room'];
    const room = this.rooms.get(roomName);
    room.delete(client);
    if (room.size === 0) {
      this.rooms.delete(roomName);
    }
    console.log(this.rooms);
  }
}
