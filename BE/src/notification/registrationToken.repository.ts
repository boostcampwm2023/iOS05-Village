import { Inject, Injectable, Scope } from '@nestjs/common';
import { BaseRepository } from '../common/base.repository';
import { DataSource } from 'typeorm';
import { REQUEST } from '@nestjs/core';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';

@Injectable({ scope: Scope.REQUEST })
export class RegistrationTokenRepository extends BaseRepository {
  constructor(dataSource: DataSource, @Inject(REQUEST) req: Request) {
    super(dataSource, req);
  }
  async findOne(userId: string): Promise<RegistrationTokenEntity> {
    return await this.getRepository(RegistrationTokenEntity).findOne({
      where: { user_hash: userId },
    });
  }

  async save(userId: string, registrationToken: string) {
    await this.getRepository(RegistrationTokenEntity).save({
      user_hash: userId,
      registration_token: registrationToken,
    });
  }

  async update(userId: string, registrationToken: string) {
    await this.getRepository(RegistrationTokenEntity).update(
      {
        user_hash: userId,
      },
      { registration_token: registrationToken },
    );
  }

  async delete(userId: string) {
    await this.getRepository(RegistrationTokenEntity).delete({
      user_hash: userId,
    });
  }
}
