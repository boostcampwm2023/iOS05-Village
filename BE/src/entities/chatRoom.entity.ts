import {
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  OneToOne,
} from 'typeorm';
import { PostEntity } from './post.entity';
import { ChatEntity } from './chat.entity';
import { UserEntity } from './user.entity';

@Entity('chat_room')
export class ChatRoomEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'int' })
  post_id: number;

  @Column({ nullable: false, charset: 'utf8', unique: true })
  writer: string;

  @Column({ nullable: false, charset: 'utf8', unique: true })
  user: string;

  @CreateDateColumn({
    type: 'timestamp',
    nullable: false,
  })
  create_date: Date;

  @UpdateDateColumn({
    type: 'timestamp',
    nullable: true,
  })
  update_date: Date;

  @DeleteDateColumn()
  delete_date: Date;

  @Column()
  last_chat_id: number;

  @Column({ default: false })
  writer_left: boolean;

  @Column({ default: false })
  user_left: boolean;

  @OneToMany(() => ChatEntity, (chat) => chat.chatRoom)
  chats: ChatEntity[];

  @OneToOne(() => ChatEntity, (chat) => chat.id)
  @JoinColumn({ name: 'last_chat_id' })
  lastChat: ChatEntity;

  @ManyToOne(() => PostEntity, (post) => post.id)
  @JoinColumn({ name: 'post_id' })
  post: PostEntity;

  @ManyToOne(() => UserEntity, (writer) => writer.user_hash)
  @JoinColumn({ name: 'writer', referencedColumnName: 'user_hash' })
  writerUser: UserEntity;

  @ManyToOne(() => UserEntity, (user) => user.user_hash)
  @JoinColumn({ name: 'user', referencedColumnName: 'user_hash' })
  userUser: UserEntity;
}
