import { Body, Controller, HttpException, Post } from '@nestjs/common';
import { JwtTokens, LoginService, SocialProperties } from './login.service';
import { AppleLoginDto } from './appleLoginDto';

@Controller('login')
export class LoginController {
  constructor(private readonly loginService: LoginService) {}

  @Post('appleOAuth') // 임시
  async signInWithApple(@Body() body: AppleLoginDto) {
    // const socialProperties: SocialProperties =
    //   await this.loginService.appleOAuth(body);
    const socialProperties = {
      OAuthDomain: 'apple',
      socialId: 'user123@example.com',
    };
    if (!socialProperties) {
      throw new HttpException('토큰이 유효하지 않음', 401);
    }
    const tokens: JwtTokens = await this.loginService.login(socialProperties);
    if (!tokens) {
      throw new HttpException('가입된 유저가 없음', 404);
    }
    return tokens;
  }
}
