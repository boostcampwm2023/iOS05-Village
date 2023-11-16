import { Controller, Get, Logger, Inject } from '@nestjs/common';
import { AppService } from './app.service';
import { LoggerService } from '@nestjs/common';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }
}
