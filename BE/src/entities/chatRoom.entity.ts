import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { PostEntity } from './post.entity';
import { BlockUserEntity } from './blockUser.entity';
import { BlockPostEntity } from './blockPost.entity';

@Entity('chat_room')
export class ChatRoomEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'int' })
  post_id: number;

  @Column({ length: 45, nullable: false, charset: 'utf8', unique: true })
  writer: string;

  @Column({ length: 45, nullable: false, charset: 'utf8', unique: true })
  sender: string;

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
}
