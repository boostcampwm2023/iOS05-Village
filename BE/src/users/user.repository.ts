import { Inject, Injectable, Scope } from '@nestjs/common';
import { BaseRepository } from '../common/base.repository';
import { DataSource } from 'typeorm';
import { REQUEST } from '@nestjs/core';
import { UserEntity } from '../entities/user.entity';

@Injectable({ scope: Scope.REQUEST })
export class UserRepository extends BaseRepository {
  constructor(dataSource: DataSource, @Inject(REQUEST) req: Request) {
    super(dataSource, req);
  }

  async softDeleteCascade(userId: string) {
    const user = await this.getRepository(UserEntity).findOne({
      where: { user_hash: userId },
      relations: ['blocker_post', 'blocker'],
    });
    await this.getRepository(UserEntity).softRemove(user);
  }
}
