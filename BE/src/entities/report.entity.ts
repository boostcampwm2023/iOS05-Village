import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

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
}
