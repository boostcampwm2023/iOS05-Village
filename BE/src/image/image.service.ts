import { HttpException, Inject, Injectable } from '@nestjs/common';
import {
  DeleteObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';
import { uuid } from 'uuidv4';
import { ConfigService } from '@nestjs/config';
import { PostImageEntity } from '../entities/postImage.entity';
import { PostImageRepository } from './postImage.repository';
import { In } from 'typeorm';

@Injectable()
export class ImageService {
  constructor(
    @Inject('S3_CLIENT')
    private readonly s3Client: S3Client,
    private postImageRepository: PostImageRepository,
    private configService: ConfigService,
  ) {}
  async uploadImage(file: Express.Multer.File) {
    const fileName = uuid();
    const command = new PutObjectCommand({
      Bucket: this.configService.get('S3_BUCKET'),
      Key: fileName,
      ACL: 'public-read',
      Body: file.buffer,
    });
    try {
      await this.s3Client.send(command);
      return `${this.configService.get('S3_ENDPOINT')}/${this.configService.get(
        'S3_BUCKET',
      )}/${fileName}`;
    } catch (e) {
      throw new HttpException('업로드에 실패하였습니다.', 500);
    }
  }

  async createPostImages(
    files: Express.Multer.File[],
    postId: number,
  ): Promise<string> {
    const postImageEntities = [];
    for (const file of files) {
      const imageLocation = await this.uploadImage(file);
      const postImageEntity = new PostImageEntity();
      postImageEntity.image_url = imageLocation;
      postImageEntity.post_id = postId;
      postImageEntities.push(postImageEntity);
    }
    await this.postImageRepository
      .getRepository(PostImageEntity)
      .save(postImageEntities);
    return postImageEntities[0].image_url;
  }

  async deleteImage(fileLocation: string) {
    const fileKey = fileLocation.split('/').pop();
    const command = new DeleteObjectCommand({
      Bucket: this.configService.get('S3_BUCKET'),
      Key: fileKey,
    });
    try {
      await this.s3Client.send(command);
    } catch (e) {
      throw new HttpException('이미지 삭제에 실패하였습니다.', 500);
    }
  }

  async removePostImages(deletedImages: string[]) {
    await this.postImageRepository
      .getRepository(PostImageEntity)
      .softDelete({ image_url: In(deletedImages) });
  }

  async updatePostImage(
    files: Array<Express.Multer.File>,
    deletedImages: string[],
    postId: number,
  ): Promise<string> {
    if (files.length > 0) {
      await this.createPostImages(files, postId);
    }
    if (deletedImages) {
      await this.removePostImages(deletedImages);
    }
    const postImageEntity = await this.postImageRepository
      .getRepository(PostImageEntity)
      .findOne({ where: { post_id: postId }, order: { id: 'ASC' } });
    return postImageEntity === null ? null : postImageEntity.image_url;
  }
}
