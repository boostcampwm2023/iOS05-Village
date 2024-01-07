import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { S3Handler } from 'src/common/S3Handler';
import { UserEntity } from '../entities/user.entity';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { AuthGuard } from 'src/common/guard/auth.guard';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';
import { FcmHandler } from 'src/common/fcmHandler';
import { GreenEyeHandler } from '../common/greenEyeHandler';
import { UserRepository } from './user.repository';
import { ImageModule } from '../image/image.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      BlockUserEntity,
      BlockPostEntity,
      RegistrationTokenEntity,
    ]),
    ImageModule,
  ],
  controllers: [UsersController],
  providers: [
    UsersService,
    S3Handler,
    AuthGuard,
    FcmHandler,
    GreenEyeHandler,
    UserRepository,
  ],
})
export class UsersModule {}
