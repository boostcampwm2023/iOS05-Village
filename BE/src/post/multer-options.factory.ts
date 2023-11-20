import { S3Client } from '@aws-sdk/client-s3';
import { Request } from 'express';
import { MulterOptions } from '@nestjs/platform-express/multer/interfaces/multer-options.interface';
import * as multerS3 from 'multer-s3';
import { ConfigService } from '@nestjs/config';
import { uuid } from 'uuidv4';

export const multerOptionsFactory = (
  configService: ConfigService,
): MulterOptions => {
  return {
    storage: multerS3({
      s3: new S3Client({
        endpoint: configService.get('S3_ENDPOINT'),
        region: configService.get('S3_REGION'),
        credentials: {
          accessKeyId: configService.get('S3_ACCESS_KEY'),
          secretAccessKey: configService.get('S3_SECRET_KEY'),
        },
      }),
      bucket: configService.get('S3_BUCKET'),
      acl: 'public-read',
      contentType: multerS3.AUTO_CONTENT_TYPE,
      key: (req: Request, file, callback) => {
        const fileName = uuid();
        callback(null, fileName);
      },
    }),
  };
};
