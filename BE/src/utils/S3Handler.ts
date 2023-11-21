import { ConfigService } from '@nestjs/config';
import {
  DeleteObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { uuid } from 'uuidv4';
import { HttpException, Injectable } from '@nestjs/common';

@Injectable()
export class S3Handler {
  s3: S3Client;
  constructor(private configService: ConfigService) {
    this.s3 = new S3Client({
      endpoint: configService.get('S3_ENDPOINT'),
      region: configService.get('S3_REGION'),
      credentials: {
        accessKeyId: configService.get('S3_ACCESS_KEY'),
        secretAccessKey: configService.get('S3_SECRET_KEY'),
      },
    });
  }
  async uploadFile(file: Express.Multer.File) {
    const fileName = uuid();
    const command = new PutObjectCommand({
      Bucket: this.configService.get('S3_BUCKET'),
      Key: fileName,
      ACL: 'public-read',
      Body: file.buffer,
    });
    try {
      await this.s3.send(command);
      return `${this.configService.get('S3_ENDPOINT')}/${this.configService.get(
        'S3_BUCKET',
      )}/${fileName}`;
    } catch (e) {
      throw new HttpException('업로드에 실패하였습니다.', 500);
    }
  }
  async deleteFile(fileLocation: string) {
    const fileKey = fileLocation.split('/').pop();
    const command = new DeleteObjectCommand({
      Bucket: this.configService.get('S3_BUCKET'),
      Key: fileKey,
    });
    try {
      await this.s3.send(command);
    } catch (e) {
      throw new HttpException('이미지 삭제에 실패하였습니다.', 500);
    }
  }
}
