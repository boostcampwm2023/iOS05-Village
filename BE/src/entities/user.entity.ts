import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('user')
export class UserEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 20, nullable: false })
  nickname: string;

  @Column({ length: 320, nullable: false })
  social_email: string;

  @Column({ length: 15, nullable: false })
  OAuth_domain: string;

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

  @Column({ type: 'tinyint', nullable: true })
  status: number;

  @Column({ length: 2048, nullable: true })
  profile_img: string;

  @Column({ length: 45, nullable: true })
  user_hash: string;
}
