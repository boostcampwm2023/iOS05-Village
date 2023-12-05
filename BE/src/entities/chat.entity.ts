import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { ChatRoomEntity } from './chatRoom.entity';
import { UserEntity } from './user.entity';

@Entity('chat')
export class ChatEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  sender: string;

  @Column({ type: 'text', nullable: false, charset: 'utf8' })
  message: string;

  @Column()
  chat_room: number;

  @Column({ type: 'boolean', default: false })
  is_read: boolean;

  @Column({ type: 'int' })
  count: number;

  @CreateDateColumn({ type: 'timestamp', nullable: false })
  create_date: Date;

  @DeleteDateColumn()
  delete_date: Date;

  @ManyToOne(() => ChatRoomEntity, (chatRoom) => chatRoom.id)
  @JoinColumn({ name: 'chat_room' })
  chatRoom: ChatRoomEntity;

  @ManyToOne(() => UserEntity, (user) => user.user_hash)
  @JoinColumn({ name: 'sender' })
  senderUser: UserEntity;
}
