import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  ManyToMany,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { PostEntity } from './post.entity';
import { BlockUserEntity } from './blockUser.entity';
import { BlockPostEntity } from './blockPost.entity';
import { ChatEntity } from './chat.entity';
import { ChatRoomEntity } from './chatRoom.entity';

@Entity('user')
export class UserEntity {
  @OneToMany(() => PostEntity, (post) => post.user)
  posts: PostEntity[];

  @OneToMany(() => BlockUserEntity, (blockUser) => blockUser.blocker)
  blocker: BlockUserEntity[];

  @OneToMany(() => BlockUserEntity, (blockUser) => blockUser.blocked_user)
  blocked: BlockUserEntity[];

  @OneToMany(() => BlockPostEntity, (blockUser) => blockUser.blocker)
  blocker_post: BlockPostEntity[];

  @OneToMany(() => ChatEntity, (chat) => chat.senderUser)
  chats: ChatEntity[];

  @OneToMany(() => ChatRoomEntity, (chatRoom) => chatRoom.writerUser)
  chatRooms: ChatRoomEntity[];

  @OneToMany(() => ChatRoomEntity, (chatRoom) => chatRoom.userUser)
  chatRooms2: ChatRoomEntity[];

  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 20, nullable: false, charset: 'utf8' })
  nickname: string;

  @Column({ length: 320, nullable: false, charset: 'utf8' })
  social_id: string;

  @Column({ length: 15, nullable: false, charset: 'utf8' })
  OAuth_domain: string;

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

  @Column({ length: 2048, nullable: true, charset: 'utf8' })
  profile_img: string;

  @Column({ length: 45, nullable: false, charset: 'utf8', unique: true })
  user_hash: string;

  @DeleteDateColumn()
  delete_date: Date;
}
