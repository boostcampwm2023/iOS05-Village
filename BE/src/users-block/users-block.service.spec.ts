import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HttpException } from '@nestjs/common';
import { UsersBlockService } from './users-block.service';
import { BlockUserEntity } from '../entities/blockUser.entity';
import { UserEntity } from '../entities/user.entity';
import { ConfigService } from '@nestjs/config';

const mockBlockUserRepository = () => ({
  save: jest.fn(),
  find: jest.fn(),
  findOne: jest.fn(),
  softDelete: jest.fn(),
});

const mockUserRepository = () => ({
  findOne: jest.fn(),
});
type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;
describe('PostsBlockService', () => {
  let service: UsersBlockService;
  let blockUserRepository: MockRepository<BlockUserEntity>;
  let userRepository: MockRepository<UserEntity>;
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersBlockService,
        {
          provide: getRepositoryToken(BlockUserEntity),
          useValue: mockBlockUserRepository(),
        },
        {
          provide: getRepositoryToken(UserEntity),
          useValue: mockUserRepository(),
        },
        {
          provide: ConfigService,
          useValue: { get: jest.fn((key: string) => 'mocked-value') },
        },
      ],
    }).compile();

    service = module.get<UsersBlockService>(UsersBlockService);
    blockUserRepository = module.get<MockRepository<BlockUserEntity>>(
      getRepositoryToken(BlockUserEntity),
    );
    userRepository = module.get<MockRepository<UserEntity>>(
      getRepositoryToken(UserEntity),
    );
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
  describe('addBlockUser()', function () {
    it('should not found', function () {
      userRepository.findOne.mockResolvedValue(null);
      expect(async () => {
        await service.addBlockUser('user', 'blocker');
      }).rejects.toThrowError(
        new HttpException('존재하지 않는 유저입니다', 404),
      );
    });
    it('should bad request', function () {
      userRepository.findOne.mockResolvedValue(new UserEntity());
      blockUserRepository.findOne.mockResolvedValue({ delete_date: null });
      expect(async () => {
        await service.addBlockUser('user', 'blocker');
      }).rejects.toThrowError(new HttpException('이미 차단된 유저입니다', 400));
    });
    it('should save', async function () {
      userRepository.findOne.mockResolvedValue(new UserEntity());
      blockUserRepository.findOne.mockResolvedValue(null);
      blockUserRepository.save.mockResolvedValue(new BlockUserEntity());
      await service.addBlockUser('user', 'blocker');
      expect(blockUserRepository.save).toHaveBeenCalledTimes(1);
    });
  });

  describe('getBlockUser', function () {
    it('should be user who has profile_img', async function () {
      const blockUsers = [];
      const blockUser = new BlockUserEntity();
      blockUser.blocked_user = 'user';
      blockUser.blockedUser = new UserEntity();
      blockUser.blockedUser.nickname = 'test';
      blockUser.blockedUser.profile_img = 'image_url';
      blockUsers.push(blockUser);
      blockUserRepository.find.mockResolvedValue(blockUsers);
      const users = await service.getBlockUser('user');
      expect(users[0].profile_img).toEqual('image_url');
    });

    it('should be user who has no profile_img', async function () {
      const blockUsers = [];
      const blockUser = new BlockUserEntity();
      blockUser.blocked_user = 'user';
      blockUser.blockedUser = new UserEntity();
      blockUser.blockedUser.nickname = 'test';
      blockUser.blockedUser.profile_img = null;
      blockUsers.push(blockUser);
      blockUserRepository.find.mockResolvedValue(blockUsers);
      const users = await service.getBlockUser('user');
      expect(users[0].profile_img).toEqual('mocked-value');
    });

    it('should be user who leave', async function () {
      const blockUsers = [];
      const blockUser = new BlockUserEntity();
      blockUser.blocked_user = 'user';
      blockUser.blockedUser = null;
      blockUsers.push(blockUser);
      blockUserRepository.find.mockResolvedValue(blockUsers);
      const users = await service.getBlockUser('user');
      expect(users[0].profile_img).toEqual(null);
      expect(users[0].nickname).toEqual(null);
      expect(users[0].user_id).toEqual('user');
    });
  });

  describe('removeBlockUser', function () {
    it('should not found', function () {
      blockUserRepository.findOne.mockResolvedValue(null);
      expect(async () => {
        await service.removeBlockUser('user', 'blocker');
      }).rejects.toThrowError(new HttpException('없는 사용자 입니다.', 404));
    });

    it('should delete', async function () {
      blockUserRepository.findOne.mockResolvedValue(new BlockUserEntity());
      await service.removeBlockUser('user', 'blocker');
      expect(blockUserRepository.softDelete).toHaveBeenCalledTimes(1);
    });
  });
});
