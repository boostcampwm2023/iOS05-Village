import {
  Body,
  Controller,
  Get,
  Headers,
  HttpException,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { LoginService, SocialProperties } from './login.service';
import { AppleLoginDto } from './dto/appleLogin.dto';
import { AuthGuard } from '../utils/auth.guard';
import { UserHash } from '../utils/auth.decorator';

@Controller()
export class LoginController {
  constructor(private readonly loginService: LoginService) {}

  @Post('login/appleOAuth') // 임시
  async signInWithApple(@Body() body: AppleLoginDto) {
    const socialProperties: SocialProperties =
      await this.loginService.appleOAuth(body);
    if (!socialProperties) {
      throw new HttpException('토큰이 유효하지 않음', 401);
    }
    return await this.loginService.login(socialProperties);
  }

  @Post('login/refresh')
  async refreshToken(@Body('refresh_token') refreshToken) {
    try {
      const payload = this.loginService.validateToken(refreshToken, 'refresh');
      return await this.loginService.refreshToken(payload);
    } catch (e) {
      throw new HttpException('refresh token이 유효하지 않음', 403);
    }
  }

  @Post('login/admin')
  loginAdmin(@Query('user') user) {
    return this.loginService.loginAdmin(user);
  }

  @Get('login/expire')
  @UseGuards(AuthGuard)
  checkAccessToken() {}

  @Post('logout')
  @UseGuards(AuthGuard)
  async logout(@Headers('Authorization') token) {
    const accessToken = token.split(' ')[1];
    await this.loginService.logout(accessToken);
  }
}
