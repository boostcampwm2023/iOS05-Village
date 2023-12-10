import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { PostEntity } from './post.entity';

@Entity('report')
export class ReportEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: false, charset: 'utf8' })
  user_hash: string;

  @Column({ nullable: false })
  post_id: number;

  @Column({ charset: 'utf8' })
  description: string;

  @Column({ nullable: false, charset: 'utf8' })
  reporter: string;

  @ManyToOne(() => UserEntity, (user) => user.user_hash)
  @JoinColumn({ name: 'user_hash', referencedColumnName: 'user_hash' })
  reportedUser: UserEntity;

  @ManyToOne(() => PostEntity, (post) => post.id)
  @JoinColumn({ name: 'post_id', referencedColumnName: 'id' })
  post: PostEntity;

  @ManyToOne(() => UserEntity, (user) => user.user_hash)
  @JoinColumn({ name: 'reporter', referencedColumnName: 'user_hash' })
  reportingUser: UserEntity;
}
