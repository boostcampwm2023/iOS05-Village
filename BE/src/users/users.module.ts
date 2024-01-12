import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from '../entities/user.entity';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { AuthGuard } from 'src/common/guard/auth.guard';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';
import { UserRepository } from './user.repository';
import { ImageModule } from '../image/image.module';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserEntity,
      BlockUserEntity,
      BlockPostEntity,
      RegistrationTokenEntity,
    ]),
    ImageModule,
    NotificationModule,
  ],
  controllers: [UsersController],
  providers: [UsersService, AuthGuard, UserRepository],
})
export class UsersModule {}
