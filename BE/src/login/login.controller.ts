import {
  Body,
  Controller,
  Get,
  HttpException,
  Post,
  UseGuards,
} from '@nestjs/common';
import { LoginService, SocialProperties } from './login.service';
import { AppleLoginDto } from './dto/appleLogin.dto';

@Controller('login')
export class LoginController {
  constructor(private readonly loginService: LoginService) {}

  @Post('appleOAuth') // 임시
  async signInWithApple(@Body() body: AppleLoginDto) {
    const socialProperties: SocialProperties =
      await this.loginService.appleOAuth(body);
    if (!socialProperties) {
      throw new HttpException('토큰이 유효하지 않음', 401);
    }
    return await this.loginService.login(socialProperties);
  }

  @Post('refresh')
  async refreshToken(@Body('refresh_token') refreshToken) {
    try {
      const payload = this.loginService.validateToken(refreshToken, 'refresh');
      return await this.loginService.refreshToken(payload);
    } catch (e) {
      throw new HttpException('refresh token이 유효하지 않음', 403);
    }
  }

  @Post('admin')
  loginAdmin(@Body('user') user) {
    return this.loginService.loginAdmin(user);
  }

  @Get('expire')
  checkAccessToken() {}
}
