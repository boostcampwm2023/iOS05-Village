import {
  Entity,
  ManyToOne,
  JoinColumn,
  PrimaryColumn,
  DeleteDateColumn,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { PostEntity } from './post.entity';

@Entity('block_user')
export class BlockUserEntity {
  @PrimaryColumn()
  blocker: string;

  @PrimaryColumn()
  blocked_user: string;

  @DeleteDateColumn()
  delete_date: Date;

  @ManyToOne(() => UserEntity, (blocker) => blocker.user_hash)
  @JoinColumn({ name: 'blocker' })
  blockerUser: UserEntity;

  @ManyToOne(() => UserEntity, (blocked) => blocked.user_hash)
  @JoinColumn({ name: 'blocked_user', referencedColumnName: 'user_hash' })
  blockedUser: UserEntity;

  @ManyToOne(() => PostEntity, (blocked) => blocked.user_hash)
  @JoinColumn({ name: 'blocked_user', referencedColumnName: 'user_hash' })
  blockedUserPost: PostEntity;
}
