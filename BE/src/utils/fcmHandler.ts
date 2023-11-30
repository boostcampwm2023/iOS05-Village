import { Injectable } from '@nestjs/common';
import admin from 'firebase-admin';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';

interface PushMessage {
  title: string;
  body: string;
  data: any;
}
@Injectable()
export class FcmHandler {
  constructor(
    private configService: ConfigService,
    @InjectRepository(RegistrationTokenEntity)
    private registrationTokenRepository: Repository<RegistrationTokenEntity>,
  ) {
    admin.initializeApp({
      credential: admin.credential.cert(
        this.configService.get('GOOGLE_APPLICATION_CREDENTIALS'),
      ),
    });
  }

  async sendPush(userId: string, pushMessage: PushMessage) {
    const registrationToken = await this.getRegistrationToken(userId);
    const message = {
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
        room_id: pushMessage.data.room_id.toString(),
      },
    };
    admin
      .messaging()
      .send(message)
      .then((response) => {
        // Response is a message ID string.
        console.log('Successfully sent message:', response);
      })
      .catch((error) => {
        console.log('Error sending message:', error);
      });
  }

  private async getRegistrationToken(userId: string): Promise<string> {
    const registrationToken = await this.registrationTokenRepository.findOne({
      where: { user_hash: userId },
    });
    if (registrationToken === null) {
      throw new Error('no registration token');
    }
    return registrationToken.registration_token;
  }
}
