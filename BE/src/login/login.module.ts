import { Module } from '@nestjs/common';
import { LoginService } from './login.service';
import { LoginController } from './login.controller';
import { JwtModule } from '@nestjs/jwt';
import { JwtConfig } from '../config/jwt.config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from '../entities/user.entity';

@Module({
  imports: [
    JwtModule.registerAsync({ useClass: JwtConfig }),
    TypeOrmModule.forFeature([UserEntity]),
  ],
  controllers: [LoginController],
  providers: [LoginService],
})
export class LoginModule {}
