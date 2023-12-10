import { Injectable } from '@nestjs/common';
import { CreateReportDto } from './createReport.dto';

@Injectable()
export class ReportService {
  async createReport(body: CreateReportDto) {}
}
