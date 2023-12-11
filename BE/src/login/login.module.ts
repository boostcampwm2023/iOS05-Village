import { Module } from '@nestjs/common';
import { LoginService } from './login.service';
import { LoginController } from './login.controller';
import { JwtModule } from '@nestjs/jwt';
import { JwtConfig } from '../config/jwt.config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from '../entities/user.entity';
import { AuthGuard } from 'src/common/guard/auth.guard';
import { FcmHandler } from '../common/fcmHandler';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';

@Module({
  imports: [
    JwtModule.registerAsync({ useClass: JwtConfig }),
    TypeOrmModule.forFeature([UserEntity, RegistrationTokenEntity]),
  ],
  controllers: [LoginController],
  providers: [LoginService, AuthGuard, FcmHandler],
})
export class LoginModule {}
