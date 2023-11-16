import { Entity, Column, ManyToOne, JoinColumn, PrimaryColumn } from 'typeorm';
import { UserEntity } from './user.entity';

@Entity('block_user')
export class BlockUserEntity {
  @PrimaryColumn()
  blocker: number;

  @PrimaryColumn()
  blocked: number;

  @Column({ nullable: false, default: 1 })
  status: number;

  @ManyToOne(() => UserEntity, (blocker) => blocker.id)
  @JoinColumn({ name: 'blocker' })
  blockerUser: UserEntity;

  @ManyToOne(() => UserEntity, (blocked) => blocked.id)
  @JoinColumn({ name: 'blocked' })
  blockedUser: UserEntity;
}
