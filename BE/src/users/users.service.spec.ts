import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { UserRepository } from './user.repository';
import { ConfigService } from '@nestjs/config';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { HttpException } from '@nestjs/common';
import { UserEntity } from '../entities/user.entity';

const mockRepository = {
  save: jest.fn(),
  findOne: jest.fn(),
  update: jest.fn(),
};

const mockUserRepository = {
  getRepository: jest.fn().mockReturnValue(mockRepository),
  softDeleteCascade: jest.fn(),
};
describe('UsersService', function () {
  let service: UsersService;
  let repository;
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: UserRepository,
          useValue: mockUserRepository,
        },
        {
          provide: ConfigService,
          useValue: { get: jest.fn((key: string) => 'default image') },
        },
        {
          provide: CACHE_MANAGER,
          useValue: { set: jest.fn((key: string) => 'mocked-value') },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    repository = module.get(UserRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('checkAuth', function () {
    it('should return 404', function () {
      repository.getRepository().findOne.mockResolvedValue(null);
      expect(async () => {
        await service.checkAuth('user', 'user');
      }).rejects.toThrowError(
        new HttpException('유저가 존재하지 않습니다.', 404),
      );
    });

    it('should return 403', function () {
      repository.getRepository().findOne.mockResolvedValue(new UserEntity());
      expect(async () => {
        await service.checkAuth('user', 'user1');
      }).rejects.toThrowError(new HttpException('수정 권한이 없습니다.', 403));
    });

    it('should pass', async function () {
      repository.getRepository().findOne.mockResolvedValue(new UserEntity());
      await service.checkAuth('user', 'user');
    });
  });

  describe('findUserById', function () {
    it('should return null', async function () {
      repository.getRepository().findOne.mockResolvedValue(null);
      const res = await service.findUserById('user');
      expect(res).toEqual(null);
    });

    it('should return user with profile image', async function () {
      const user = new UserEntity();
      user.profile_img = 'www.test.com';
      user.nickname = 'user';
      repository.getRepository().findOne.mockResolvedValue(user);
      const res = await service.findUserById('user');
      expect(res.nickname).toEqual('user');
      expect(res.profile_img).toEqual('www.test.com');
    });

    it('should return user with default profile image', async function () {
      const user = new UserEntity();
      user.profile_img = null;
      user.nickname = 'user';
      repository.getRepository().findOne.mockResolvedValue(user);
      const res = await service.findUserById('user');
      expect(res.nickname).toEqual('user');
      expect(res.profile_img).toEqual('default image');
    });
  });

  describe('updateUserById', function () {
    it('should update only nickname', async function () {
      const nickname = 'test';
      const imageLocation = null;
      const userId = 'user';
      const updateEntity = new UserEntity();
      updateEntity.nickname = nickname;
      updateEntity.profile_img = undefined;
      await service.updateUserById(nickname, imageLocation, userId);
      expect(repository.getRepository().update).toHaveBeenCalledWith(
        {
          user_hash: userId,
        },
        updateEntity,
      );
    });

    it('should update only image', async function () {
      const nickname = null;
      const imageLocation = 'test';
      const userId = 'user';
      const updateEntity = new UserEntity();
      updateEntity.nickname = undefined;
      updateEntity.profile_img = imageLocation;
      await service.updateUserById(nickname, imageLocation, userId);
      expect(repository.getRepository().update).toHaveBeenCalledWith(
        {
          user_hash: userId,
        },
        updateEntity,
      );
    });

    it('should update all', async function () {
      const nickname = 'test';
      const imageLocation = 'test';
      const userId = 'user';
      const updateEntity = new UserEntity();
      updateEntity.nickname = nickname;
      updateEntity.profile_img = imageLocation;
      await service.updateUserById(nickname, imageLocation, userId);
      expect(repository.getRepository().update).toHaveBeenCalledWith(
        {
          user_hash: userId,
        },
        updateEntity,
      );
    });
  });

  describe('', function () {});
});
