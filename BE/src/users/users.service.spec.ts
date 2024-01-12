import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { UserRepository } from './user.repository';
import { ConfigService } from '@nestjs/config';
import { CACHE_MANAGER } from '@nestjs/cache-manager';

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
});
