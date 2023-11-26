import {
  Entity,
  ManyToOne,
  JoinColumn,
  PrimaryColumn,
  DeleteDateColumn,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { PostEntity } from './post.entity';

@Entity('block_post')
export class BlockPostEntity {
  @PrimaryColumn()
  blocker: string;

  @PrimaryColumn()
  blocked_post: number;

  @DeleteDateColumn()
  delete_date: Date;

  @ManyToOne(() => UserEntity, (blocker) => blocker.user_hash)
  @JoinColumn({ name: 'blocker', referencedColumnName: 'user_hash' })
  blockerUser: UserEntity;

  @ManyToOne(() => PostEntity, (blocked_post) => blocked_post.id)
  @JoinColumn({ name: 'blocked_post' })
  blockedPost: PostEntity;
}
