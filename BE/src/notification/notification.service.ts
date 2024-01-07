import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import admin from 'firebase-admin';
import { PushMessage } from '../common/fcmHandler';
import { RegistrationTokenRepository } from './registrationToken.repository';

@Injectable()
export class NotificationService {
  private readonly logger = new Logger('ChatsGateway');
  constructor(
    private configService: ConfigService,
    private registrationTokenRepository: RegistrationTokenRepository,
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

  async sendChatNotification(userId: string, pushMessage: PushMessage) {
    const registrationToken = await this.getRegistrationToken(userId);
    if (!registrationToken) {
      throw new Error('no registration token');
    }
    const message = this.createChatNotificationMessage(
      registrationToken,
      pushMessage,
    );
    try {
      const response = await admin.messaging().send(message);
      this.logger.debug(
        `Push Notification Success : ${response} `,
        'FcmHandler',
      );
    } catch (e) {
      throw new Error('fail to send chat notification');
    }
  }

  createChatNotificationMessage(
    registrationToken: string,
    pushMessage: PushMessage,
  ) {
    return {
      token: registrationToken,
      notification: {
        title: pushMessage.title,
        body: pushMessage.body,
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
          },
        },
      },
      data: {
        ...pushMessage.data,
      },
    };
  }

  private async getRegistrationToken(userId: string): Promise<string> {
    const registrationToken =
      await this.registrationTokenRepository.findOne(userId);
    if (registrationToken === null) {
      this.logger.error('토큰이 없습니다.', 'FcmHandler');
    }
    return registrationToken.registration_token;
  }

  async registerToken(userId, registrationToken) {
    const registrationTokenEntity =
      await this.registrationTokenRepository.findOne(userId);
    if (registrationTokenEntity === null) {
      await this.registrationTokenRepository.save(userId, registrationToken);
    } else {
      await this.registrationTokenRepository.update(userId, registrationToken);
    }
  }

  async removeRegistrationToken(userId: string) {
    await this.registrationTokenRepository.delete(userId);
  }
}
