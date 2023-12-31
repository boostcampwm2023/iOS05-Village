import { Injectable, Logger } from '@nestjs/common';
import admin from 'firebase-admin';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';

export interface PushMessage {
  title: string;
  body: string;
  data: any;
}
@Injectable()
export class FcmHandler {
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

  async sendPush(userId: string, pushMessage: PushMessage) {
    try {
      const registrationToken = await this.getRegistrationToken(userId);
      const message = this.createPushMessage(registrationToken, pushMessage);
      admin
        .messaging()
        .send(message)
        .then((response) => {
          this.logger.debug(
            `Push Notification Success : ${response} `,
            'FcmHandler',
          );
        })
        .catch((error) => {
          this.logger.error(error, 'FcmHandler');
          this.removeRegistrationToken(userId);
        });
    } catch {}
  }

  private async getRegistrationToken(userId: string): Promise<string> {
    const registrationToken = await this.registrationTokenRepository.findOne({
      where: { user_hash: userId },
    });
    if (registrationToken === null) {
      this.logger.error('토큰이 없습니다.', 'FcmHandler');
      throw new Error('no registration token');
    }
    return registrationToken.registration_token;
  }

  async removeRegistrationToken(userId: string) {
    await this.registrationTokenRepository.delete({ user_hash: userId });
  }

  createPushMessage(registrationToken: string, pushMessage: PushMessage) {
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

  createChatPushMessage(
    nickname: string,
    message: string,
    roomId: number,
  ): PushMessage {
    return {
      title: nickname,
      body: message,
      data: {
        room_id: roomId.toString(),
      },
    };
  }
}
