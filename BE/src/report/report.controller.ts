import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { CreateReportDto } from './createReport.dto';
import { ReportService } from './report.service';
import { AuthGuard } from '../utils/auth.guard';
import { UserHash } from '../utils/auth.decorator';

@Controller('report')
@UseGuards(AuthGuard)
export class ReportController {
  constructor(private readonly reportService: ReportService) {}
  @Post()
  async createReport(
    @Body() body: CreateReportDto,
    @UserHash() userId: string,
  ) {
    await this.reportService.createReport(body, userId);
  }
}