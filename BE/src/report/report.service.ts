import { Injectable } from '@nestjs/common';
import { CreateReportDto } from './createReport.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ReportEntity } from '../entities/report.entity';

@Injectable()
export class ReportService {
  constructor(
    @InjectRepository(ReportEntity)
    private reportRepository: Repository<ReportEntity>,
  ) {}
  async createReport(body: CreateReportDto) {}
}
