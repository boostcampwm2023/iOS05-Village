import { Test, TestingModule } from '@nestjs/testing';
import { PostService } from './post.service';
import { PostRepository } from './post.repository';
import { PostListDto } from './dto/postList.dto';
import { PostEntity } from '../entities/post.entity';
import { PostImageEntity } from '../entities/postImage.entity';
import { HttpException } from '@nestjs/common';
import { BlockPostEntity } from '../entities/blockPost.entity';

const mockRepository = {
  save: jest.fn(),
  softDelete: jest.fn(),
  findOne: jest.fn(),
};

const mockPostRepository = {
  getRepository: jest.fn().mockReturnValue(mockRepository),
  findExceptBlock: jest.fn(),
  findOneWithBlock: jest.fn(),
  softDeleteCascade: jest.fn(),
};
describe('PostService', function () {
  let service: PostService;
  let postRepository;
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PostService,
        {
          provide: PostRepository,
          useValue: mockPostRepository,
        },
      ],
    }).compile();

    service = module.get<PostService>(PostService);
    postRepository = module.get(PostRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findPosts', function () {
    const postEntities: PostEntity[] = [];
    for (let i = 0; i < 20; i++) {
      const postEntity = new PostEntity();
      postEntity.title = 'title' + i;
      postEntity.price = 10000;
      postEntity.id = i;
      postEntity.user_hash = 'user' + i;
      postEntity.is_request = false;
      postEntity.thumbnail = 'www.test.com' + i;
      postEntity.start_date = new Date();
      postEntity.end_date = new Date();
      postEntities.push(postEntity);
    }
    it('should return posts', async function () {
      postRepository.findExceptBlock.mockResolvedValue(postEntities);
      const res = await service.findPosts(new PostListDto(), 'user');
      expect(res.length).toEqual(20);
    });
  });

  describe('findPostById', function () {
    const postEntity = new PostEntity();
    postEntity.title = 'title';
    postEntity.price = 10000;
    postEntity.id = 1;
    postEntity.user_hash = 'user';
    postEntity.is_request = false;
    postEntity.thumbnail = 'www.test.com';
    postEntity.start_date = new Date();
    postEntity.end_date = new Date();
    postEntity.blocked_posts = [new BlockPostEntity()];
    postEntity.blocked_users = [];
    postEntity.post_images = [new PostImageEntity()];

    it('should throw 404', async function () {
      postRepository.findOneWithBlock.mockResolvedValue(null);
      await expect(async () => {
        await service.findPostById(1, 'user');
      }).rejects.toThrowError(new HttpException('없는 게시물입니다.', 404));
    });

    it('should throw 400', async function () {
      postRepository.findOneWithBlock.mockResolvedValue(postEntity);
      await expect(async () => {
        await service.findPostById(1, 'user');
      }).rejects.toThrowError(new HttpException('차단한 게시물입니다.', 400));
    });

    it('should return post', async function () {
      postEntity.blocked_posts.pop();
      postRepository.findOneWithBlock.mockResolvedValue(postEntity);
      const res = await service.findPostById(1, 'user');
      expect(res.title).toEqual('title');
    });
  });

  describe('checkAuth', function () {
    const post = new PostEntity();
    post.user_hash = 'user1';
    it('should throw 404', function () {
      postRepository.getRepository().findOne.mockResolvedValue(null);
      expect(async () => {
        await service.checkAuth(1, 'user');
      }).rejects.toThrowError(new HttpException('게시글이 없습니다.', 404));
    });

    it('should throw 403', function () {
      postRepository.getRepository().findOne.mockResolvedValue(post);
      expect(async () => {
        await service.checkAuth(1, 'user');
      }).rejects.toThrowError(new HttpException('수정 권한이 없습니다.', 403));
    });

    it('should pass checkAuth', async function () {
      postRepository.getRepository().findOne.mockResolvedValue(post);
      await service.checkAuth(1, 'user1');
    });
  });
});
