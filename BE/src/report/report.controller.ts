import { Body, Controller, Post } from '@nestjs/common';
import { CreateReportDto } from './createReport.dto';
import { ReportService } from './report.service';

@Controller('report')
export class ReportController {
  constructor(private readonly reportService: ReportService) {}
  @Post()
  async createReport(@Body() body: CreateReportDto) {
    await this.reportService.createReport(body);
  }
}
