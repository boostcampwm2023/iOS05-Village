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
}
