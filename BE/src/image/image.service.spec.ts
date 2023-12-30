import { Test, TestingModule } from '@nestjs/testing';
import { ImageService } from './image.service';
import { PostImageRepository } from './postImage.repository';
import { ConfigService } from '@nestjs/config';
import { HttpException } from '@nestjs/common';
import { PostImageEntity } from '../entities/postImage.entity';
jest.mock('uuid', () => ({
  v4: jest.fn(() => 'fixed-uuid-value'),
}));

const mockRepository = {
  save: jest.fn(),
  softDelete: jest.fn(),
  findOne: jest.fn(),
};

const mockPostImageRepository = {
  getRepository: jest.fn().mockReturnValue(mockRepository),
};

describe('ImageService', () => {
  let service: ImageService;
  let postImageRepository;
  let s3ClientMock;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ImageService,
        {
          provide: PostImageRepository,
          useValue: mockPostImageRepository,
        },
        {
          provide: ConfigService,
          useValue: { get: jest.fn((key: string) => 'mocked-value') },
        },
        {
          provide: 'S3_CLIENT',
          useValue: { send: jest.fn() },
        },
      ],
    }).compile();

    service = module.get<ImageService>(ImageService);
    postImageRepository = module.get<jest.Mock>(PostImageRepository);
    s3ClientMock = module.get('S3_CLIENT');
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('uploadImage', function () {
    const file: Express.Multer.File = {
      buffer: Buffer.from('test-content'),
      originalname: 'test.jpg',
      mimetype: 'image/jpeg',
      size: 1024,
      fieldname: 'image',
      encoding: '7bit',
      destination: '',
      filename: 'test.jpg',
      path: '',
      stream: {} as any,
    };
    it('should upload file', async function () {
      s3ClientMock.send.mockReturnValue(undefined);
      const res = await service.uploadImage(file);
      expect(res).toEqual('mocked-value/mocked-value/fixed-uuid-value');
    });

    it('should fail to upload', function () {
      s3ClientMock.send.mockRejectedValue(new Error('test'));
      expect(async () => {
        await service.uploadImage(file);
      }).rejects.toThrowError(
        new HttpException('업로드에 실패하였습니다.', 500),
      );
    });
  });

  describe('createPostImages', function () {
    const files = [];
    for (let i = 0; i < 7; i++) {
      const file: Express.Multer.File = {
        buffer: Buffer.from(`test-content ${i}`),
        originalname: 'test.jpg',
        mimetype: 'image/jpeg',
        size: 1024,
        fieldname: 'image',
        encoding: '7bit',
        destination: '',
        filename: 'test.jpg',
        path: '',
        stream: {} as any,
      };
      files.push(file);
    }

    it('should create images', async function () {
      s3ClientMock.send.mockReturnValue(undefined);
      postImageRepository.getRepository().save.mockResolvedValue('test');
      const res = await service.createPostImages(files, 3);
      expect(res).toEqual('mocked-value/mocked-value/fixed-uuid-value');
      expect(s3ClientMock.send).toHaveBeenCalledTimes(7);
      expect(postImageRepository.getRepository().save).toHaveBeenCalledTimes(1);
    });

    it('should fail to upload images', async function () {
      s3ClientMock.send.mockRejectedValue(new Error('fail to upload image'));
      await expect(async () => {
        await service.createPostImages(files, 3);
      }).rejects.toThrowError(
        new HttpException('업로드에 실패하였습니다.', 500),
      );
    });

    it('should fail to create images', async function () {
      postImageRepository.getRepository().save.mockResolvedValue('test');
      postImageRepository
        .getRepository()
        .save.mockRejectedValue(new Error('fail to create images'));
      await expect(async () => {
        await service.createPostImages(files, 3);
      }).rejects.toThrowError();
      expect(s3ClientMock.send).toHaveBeenCalledTimes(7);
    });
  });

  describe('removePostImages', function () {
    const imageLocations = ['test1', 'test2', 'test3'];
    it('should remove post images', async function () {
      await service.removePostImages(imageLocations);
      expect(
        postImageRepository.getRepository().softDelete,
      ).toHaveBeenCalledTimes(1);
    });

    it('should fail to remove images', async function () {
      postImageRepository
        .getRepository()
        .softDelete.mockRejectedValue(new Error('fail to remove images'));
      await expect(async () => {
        await service.removePostImages(imageLocations);
      }).rejects.toThrowError();
    });
  });

  describe('', function () {
    const files = [];
    for (let i = 0; i < 2; i++) {
      const file: Express.Multer.File = {
        buffer: Buffer.from(`test-content ${i}`),
        originalname: 'test.jpg',
        mimetype: 'image/jpeg',
        size: 1024,
        fieldname: 'image',
        encoding: '7bit',
        destination: '',
        filename: 'test.jpg',
        path: '',
        stream: {} as any,
      };
      files.push(file);
    }
    it('should update Post Image', async function () {
      const postImageEntity: PostImageEntity = {
        id: 1,
        post_id: 1,
        image_url: 'updatedImageUrl',
        delete_date: null,
        post: null,
      };
      postImageRepository
        .getRepository()
        .findOne.mockResolvedValue(postImageEntity);
      jest.spyOn(service, 'createPostImages').mockResolvedValue(undefined);
      jest.spyOn(service, 'removePostImages').mockResolvedValue(undefined);
      const deletedImages = ['image1', 'image2'];
      const postId = 1;

      const result = await service.updatePostImage(
        files,
        deletedImages,
        postId,
      );

      expect(service.createPostImages).toHaveBeenCalledWith(files, postId);
      expect(service.removePostImages).toHaveBeenCalledWith(deletedImages);
      expect(postImageRepository.getRepository().findOne).toHaveBeenCalledWith({
        where: { post_id: postId },
        order: { id: 'ASC' },
      });
      expect(result).toBe('updatedImageUrl');
    });

    it('should return null', async function () {
      jest.spyOn(service, 'createPostImages').mockResolvedValue(undefined);
      jest.spyOn(service, 'removePostImages').mockResolvedValue(undefined);
      postImageRepository.getRepository().findOne.mockResolvedValue(null);
      const deletedImages = ['image1', 'image2']; // Replace with your actual deleted image data
      const postId = 1;

      const result = await service.updatePostImage(
        files,
        deletedImages,
        postId,
      );

      expect(result).toBeNull();
    });
  });
});
