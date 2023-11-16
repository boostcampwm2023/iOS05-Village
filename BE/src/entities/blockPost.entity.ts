import { Entity, Column, ManyToOne, JoinColumn, PrimaryColumn } from 'typeorm';
import { UserEntity } from './user.entity';
import { PostEntity } from './post.entity';

@Entity('block_post')
export class BlockPostEntity {
  @PrimaryColumn()
  blocker: number;

  @PrimaryColumn()
  blocked_post: number;

  @Column({ nullable: false, default: 1 })
  status: number;

  @ManyToOne(() => UserEntity, (blocker) => blocker.id)
  @JoinColumn({ name: 'blocker' })
  blockerUser: UserEntity;

  @ManyToOne(() => UserEntity, (blocked_post) => blocked_post.id)
  @JoinColumn({ name: 'blocked_post' })
  blockedPost: PostEntity;
}
