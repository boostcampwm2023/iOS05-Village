import { PostsBlockService } from './posts-block.service';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BlockPostEntity } from '../entities/blockPost.entity';
import { PostEntity } from '../entities/post.entity';
import { HttpException } from '@nestjs/common';

const mockBlockPostRepository = () => ({
  save: jest.fn(),
  find: jest.fn(),
  findOne: jest.fn(),
  softDelete: jest.fn(),
});

const mockPostRepository = () => ({
  findOne: jest.fn(),
});
type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;
describe('PostsBlockService', () => {
  let service: PostsBlockService;
  let blockPostRepository: MockRepository<BlockPostEntity>;
  let postRepository: MockRepository<PostEntity>;
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PostsBlockService,
        {
          provide: getRepositoryToken(BlockPostEntity),
          useValue: mockBlockPostRepository(),
        },
        {
          provide: getRepositoryToken(PostEntity),
          useValue: mockPostRepository(),
        },
      ],
    }).compile();

    service = module.get<PostsBlockService>(PostsBlockService);
    blockPostRepository = module.get<MockRepository<BlockPostEntity>>(
      getRepositoryToken(BlockPostEntity),
    );
    postRepository = module.get<MockRepository<PostEntity>>(
      getRepositoryToken(PostEntity),
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
  describe('createPostsBlock()', () => {
    it('should success', function () {
      postRepository.findOne.mockResolvedValue(new PostEntity());
      blockPostRepository.findOne.mockResolvedValue(new BlockPostEntity());
      blockPostRepository.save.mockResolvedValue(new BlockPostEntity());
      service.createPostsBlock('qwe', 123);
    });

    it('should not found', async function () {
      postRepository.findOne.mockResolvedValue(null);
      await expect(async () => {
        await service.createPostsBlock('qwe', 123);
      }).rejects.toThrowError(new HttpException('없는 게시물입니다.', 404));
    });

    it('should be bad request', async function () {
      postRepository.findOne.mockResolvedValue(new PostEntity());
      blockPostRepository.findOne.mockResolvedValue({ delete_date: null });
      await expect(async () => {
        await service.createPostsBlock('qwe', 123);
      }).rejects.toThrowError(new HttpException('이미 차단 되었습니다.', 400));
    });
  });

  describe('getRequestFilter', function () {
    it('should return undefined', function () {
      const result = service.getRequestFilter(undefined);
      expect(result).toEqual(undefined);
    });
    it('should return is_request = true', function () {
      const result = service.getRequestFilter(1);
      expect(result).toEqual({ is_request: true });
    });
    it('should return is_request = false', function () {
      const result = service.getRequestFilter(0);
      expect(result).toEqual({ is_request: false });
    });
  });

  describe('findBlockedPosts', function () {
    const blockLists = [];
    for (let i = 0; i < 5; i++) {
      const block: BlockPostEntity = new BlockPostEntity();
      block.blocker = 'user';
      block.blocked_post = i;
      block.delete_date = null;
      block.blockedPost = new PostEntity();
      block.blockedPost.title = 'title' + i.toString();
      block.blockedPost.thumbnail = 'www.image.com';
      block.blockedPost.id = i;
      block.blockedPost.start_date = new Date();
      block.blockedPost.end_date = new Date();
      block.blockedPost.is_request = i % 2 === 1;
      block.blockedPost.price = i % 2 === 1 ? null : 10000;
      blockLists.push(block);
    }
    it('should return all kind', async function () {
      blockPostRepository.find.mockResolvedValue(blockLists);
      const result = await service.findBlockedPosts('user', undefined);
      expect(result.length).toEqual(5);
    });
    it('should return request post', async function () {
      const blocks = blockLists.filter((blockList) => {
        return blockList.blockedPost.is_request === true;
      });
      blockPostRepository.find.mockResolvedValue(blocks);
      const result = await service.findBlockedPosts('user', 1);
      const nullable = result
        .map((res) => res.price)
        .every((price) => price === null);
      expect(nullable).toEqual(true);
    });
  });
  describe('removeBlockPosts', function () {
    it('should not found', function () {
      blockPostRepository.findOne.mockResolvedValue(null);
      expect(async () => {
        await service.removeBlockPosts(1, 'user');
      }).rejects.toThrowError(
        new HttpException('게시글이 존재하지 않습니다.', 404),
      );
    });
    it('should remove', async function () {
      blockPostRepository.findOne.mockResolvedValue(new BlockPostEntity());
      await service.removeBlockPosts(1, 'user');
      expect(blockPostRepository.findOne).toHaveBeenCalledTimes(1);
      expect(blockPostRepository.softDelete).toHaveBeenCalledTimes(1);
    });
  });
});
