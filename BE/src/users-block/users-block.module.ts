import { Module } from '@nestjs/common';
import { UsersBlockService } from './users-block.service';
import { UsersBlockController } from './users-block.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BlockUserEntity } from 'src/entities/blockUser.entity';
import { UserEntity } from 'src/entities/user.entity';
import { AuthGuard } from 'src/utils/auth.guard';

@Module({
  imports: [TypeOrmModule.forFeature([BlockUserEntity, UserEntity])],
  controllers: [UsersBlockController],
  providers: [UsersBlockService, AuthGuard],
})
export class UsersBlockModule {}
