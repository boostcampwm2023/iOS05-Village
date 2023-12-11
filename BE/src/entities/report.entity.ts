import {
  Column,
  Entity,
  ManyToOne,
  PrimaryColumn,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { PostEntity } from './post.entity';

@Entity('report')
export class ReportRepository {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: false, charset: 'utf8' })
  user_hash: string;

  @Column({ nullable: false })
  postId: number;

  @Column({ charset: 'utf8' })
  description: string;

  @ManyToOne(() => UserEntity, (user) => user.user_hash)
  user: UserEntity;

  @ManyToOne(() => PostEntity, (post) => post.id)
  post: PostEntity;
}
