import { Test, TestingModule } from '@nestjs/testing';
import { PostRepository } from './post.repository';
import { getRepositoryToken } from '@nestjs/typeorm';
import { PostEntity } from '../entities/post.entity';
import { DataSource } from 'typeorm';

const mockDataSource = {
  createEntityManager: jest.fn(),
};
describe('', () => {
  let repository: PostRepository;
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PostRepository,
        { provide: DataSource, useValue: mockDataSource },
        { provide: getRepositoryToken(PostEntity), useValue: {} },
      ],
    }).compile();
    repository = module.get<PostRepository>(PostRepository);
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('createPost()', () => {
    it('should success (nothing)', async function () {
      const res = repository.createOption({
        cursorId: undefined,
        requestFilter: undefined,
        writer: undefined,
        searchKeyword: undefined,
      });
      expect(res).toBe('post.id > -1');
    });
    it('should success (page)', async function () {
      const res = repository.createOption({
        cursorId: 1,
        requestFilter: undefined,
        writer: undefined,
        searchKeyword: undefined,
      });
      expect(res).toBe('post.id < 1');
    });
    it('should success (more than two options)', async function () {
      const res = repository.createOption({
        cursorId: 1,
        requestFilter: undefined,
        writer: 'user',
        searchKeyword: undefined,
      });
      expect(res).toBe("post.id < 1 AND post.user_hash = 'user'");
    });
  });
});
