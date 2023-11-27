import { Module } from '@nestjs/common';
import { LoginService } from './login.service';
import { LoginController } from './login.controller';
import { JwtModule } from '@nestjs/jwt';
import { JwtConfig } from '../config/jwt.config';

@Module({
  imports: [JwtModule.registerAsync({ useClass: JwtConfig })],
  controllers: [LoginController],
  providers: [LoginService],
})
export class LoginModule {}
