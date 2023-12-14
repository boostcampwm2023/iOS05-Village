import { HttpException, Injectable } from '@nestjs/common';
import { CreateReportDto } from './dto/createReport.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ReportEntity } from '../entities/report.entity';
import { PostEntity } from '../entities/post.entity';
@Injectable()
export class ReportService {
  constructor(
    @InjectRepository(ReportEntity)
    private reportRepository: Repository<ReportEntity>,
    @InjectRepository(PostEntity)
    private postRepository: Repository<PostEntity>,
  ) {}
  async createReport(body: CreateReportDto, userId: string) {
    const isExist = await this.postRepository.exist({
      where: { id: body.post_id },
    });
    if (body.user_id === userId) {
      throw new HttpException('자신의 게시글은 신고 할 수 없습니다.', 400);
    }
    if (!isExist) {
      throw new HttpException('신고할 대상이 존재 하지 않습니다.', 404);
    }
    const reportEntity = new ReportEntity();
    reportEntity.post_id = body.post_id;
    reportEntity.user_hash = body.user_id;
    reportEntity.description = body.description;
    reportEntity.reporter = userId;
    await this.reportRepository.save(reportEntity);
  }
}
