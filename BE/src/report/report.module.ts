import { Module } from '@nestjs/common';
import { ReportController } from './report.controller';
import { ReportService } from './report.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReportEntity } from '../entities/report.entity';
import { PostEntity } from '../entities/post.entity';
import { UserEntity } from '../entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ReportEntity, PostEntity, UserEntity])],
  controllers: [ReportController],
  providers: [ReportService],
})
export class ReportModule {}
