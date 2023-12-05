import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
  DeleteDateColumn,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { PostImageEntity } from './postImage.entity';
import { BlockPostEntity } from './blockPost.entity';
import { ChatRoomEntity } from './chatRoom.entity';

@Entity('post')
export class PostEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100, nullable: false, charset: 'utf8' })
  title: string;

  @Column({ nullable: true })
  price: number;

  @Column({ type: 'text', nullable: false, charset: 'utf8' })
  description: string;

  @Column({ nullable: false })
  user_hash: string;

  @ManyToOne(() => UserEntity, (user) => user.user_hash)
  @JoinColumn({ name: 'user_hash', referencedColumnName: 'user_hash' })
  user: UserEntity;

  @Column({ type: 'datetime', nullable: false })
  start_date: Date;

  @Column({ type: 'datetime', nullable: false })
  end_date: Date;

  @Column({ type: 'boolean', nullable: false })
  is_request: boolean;

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

  @Column({ length: 2048, nullable: true, charset: 'utf8' })
  thumbnail: string;

  @OneToMany(() => PostImageEntity, (post_image) => post_image.post)
  post_images: PostImageEntity[];

  @OneToMany(() => BlockPostEntity, (post_image) => post_image.blocked_post)
  blocked_posts: BlockPostEntity[];
}
