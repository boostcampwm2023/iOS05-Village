import { Module } from '@nestjs/common';
import { NotificationService } from './notification.service';
import { RegistrationTokenRepository } from './registrationToken.repository';

@Module({
  exports: [NotificationService],
  providers: [NotificationService, RegistrationTokenRepository],
})
export class NotificationModule {}
