import { Module } from '@nestjs/common';
import { ImageService } from './image.service';
import { S3Provider } from '../config/s3.config';
import { PostImageRepository } from './postImage.repository';

@Module({
  providers: [ImageService, ...S3Provider, PostImageRepository],
  exports: [ImageService],
})
export class ImageModule {}
