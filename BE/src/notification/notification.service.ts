import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';
import { Repository } from 'typeorm';
import admin from 'firebase-admin';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger('ChatsGateway');
  constructor(
    private configService: ConfigService,
    @InjectRepository(RegistrationTokenEntity)
    private registrationTokenRepository: Repository<RegistrationTokenEntity>,
  ) {
    if (admin.apps.length === 0) {
      admin.initializeApp({
        credential: admin.credential.cert(
          this.configService.get('GOOGLE_APPLICATION_CREDENTIALS'),
        ),
      });
      this.logger.log('Firebase Admin initialized');
    }
  }

  async registerToken(userId, registrationToken) {
    const registrationTokenEntity =
      await this.registrationTokenRepository.findOne({
        where: { user_hash: userId },
      });
    if (registrationTokenEntity === null) {
      await this.registrationTokenRepository.save({
        user_hash: userId,
        registration_token: registrationToken,
      });
    } else {
      await this.registrationTokenRepository.update(
        {
          user_hash: userId,
        },
        { registration_token: registrationToken },
      );
    }
  }

  async removeRegistrationToken(userId: string) {
    await this.registrationTokenRepository.delete({ user_hash: userId });
  }
}
