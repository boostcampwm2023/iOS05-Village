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
          useValue: { get: jest.fn((key: string) => 'mocked-value') },
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
});
