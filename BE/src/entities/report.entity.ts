import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { UserEntity } from './user.entity';
import { PostEntity } from './post.entity';

@Entity('report')
export class ReportEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: false, charset: 'utf8' })
  user_hash: string;

  @Column({ nullable: false, charset: 'utf8' })
  post_id: number;

  @Column({ charset: 'utf8' })
  description: string;

  @ManyToOne(() => UserEntity, (user) => user.user_hash)
  user: UserEntity;

  @ManyToOne(() => PostEntity, (post) => post.id)
  post: PostEntity;
}
