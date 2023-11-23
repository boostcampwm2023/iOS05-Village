import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { S3Handler } from 'src/utils/S3Handler';
import { UserEntity } from '../entities/user.entity';
import { S3Handler } from '../utils/S3Handler';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity])],
  controllers: [UsersController],
  providers: [UsersService, S3Handler],
})
export class UsersModule {}
