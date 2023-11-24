import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  DeleteDateColumn,
} from 'typeorm';
import { PostEntity } from './post.entity';

@Entity('post_image')
export class PostImageEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 2048, charset: 'utf8' })
  image_url: string;

  @Column({ nullable: false })
  post_id: number;

  @DeleteDateColumn()
  delete_date: Date;

  @ManyToOne(() => PostEntity, (post) => post.id)
  @JoinColumn({ name: 'post_id' })
  post: PostEntity;
}
