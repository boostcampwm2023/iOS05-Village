import { Entity, Column, ManyToOne, JoinColumn, PrimaryColumn } from 'typeorm';
import { UserEntity } from './user.entity';

@Entity('block_user')
export class BlockUserEntity {
  @PrimaryColumn()
  blocker: string;

  @PrimaryColumn()
  blocked_user: string;

  @Column({ nullable: false, default: true })
  status: boolean;

  @ManyToOne(() => UserEntity, (blocker) => blocker.user_hash)
  @JoinColumn({ name: 'blocker' })
  blockerUser: UserEntity;

  @ManyToOne(() => UserEntity, (blocked) => blocked.user_hash)
  @JoinColumn({ name: 'blocked_user' })
  blockedUser: UserEntity;
}
