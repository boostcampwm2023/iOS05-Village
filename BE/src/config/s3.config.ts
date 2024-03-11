import { ConfigModule, ConfigService } from '@nestjs/config';
import { S3Client } from '@aws-sdk/client-s3';

export const S3Provider = [
  {
    provide: 'S3_CLIENT',
    import: [ConfigModule],
    inject: [ConfigService],
    useFactory: (configService: ConfigService) => {
      return new S3Client({
        endpoint: configService.get('S3_ENDPOINT'),
        region: configService.get('S3_REGION'),
        credentials: {
          accessKeyId: configService.get('S3_ACCESS_KEY'),
          secretAccessKey: configService.get('S3_SECRET_KEY'),
        },
      });
    },
  },
];
