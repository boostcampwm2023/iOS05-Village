import { Body, Controller, Post } from '@nestjs/common';
import { LoginService } from './login.service';
import { AppleLoginDto } from './dto/appleLogin.dto';

@Controller('login')
export class LoginController {
  constructor(private readonly loginService: LoginService) {}
}
