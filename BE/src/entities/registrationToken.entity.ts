import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  OneToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserEntity } from './user.entity';

@Entity('registration_token')
export class RegistrationTokenEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 45, nullable: false, charset: 'utf8', unique: true })
  user_hash: string;

  @Column({ length: 4096, nullable: false, charset: 'utf8' })
  registration_token: string;

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

  @OneToOne(() => UserEntity, (user) => user.user_hash)
  @JoinColumn({ name: 'user_hash', referencedColumnName: 'user_hash' })
  user: UserEntity;
}
