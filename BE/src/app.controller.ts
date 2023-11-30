import { Controller, Get, Redirect } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  // @Get()
  // home(): string {
  //   return this.appService.getHello();
  // }

  @Get('API')
  @Redirect(
    'https://app.swaggerhub.com/apis/koomin1227/Village/1.0.0#/posts/get_posts',
    301,
  )
  getApiDocs() {}
}
