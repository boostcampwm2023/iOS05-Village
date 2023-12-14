import { Controller, Get, Redirect } from '@nestjs/common';

@Controller()
export class AppController {
  constructor() {}

  @Get('API')
  @Redirect(
    'https://app.swaggerhub.com/apis/koomin1227/Village/1.0.0#/posts/get_posts',
    301,
  )
  getApiDocs() {}
}
