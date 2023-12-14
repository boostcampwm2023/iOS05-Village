import { Repository } from 'typeorm';
import { ReportService } from './report.service';
import { ReportEntity } from '../entities/report.entity';
import { PostEntity } from '../entities/post.entity';
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { CreateReportDto } from './dto/createReport.dto';
import { HttpException } from '@nestjs/common';

const mockReportRepository = () => ({
  save: jest.fn(),
  find: jest.fn(),
  findOne: jest.fn(),
  softDelete: jest.fn(),
});

const mockPostRepository = () => ({
  findOne: jest.fn(),
  exist: jest.fn(),
});

type MockRepository<T = any> = Partial<Record<keyof Repository<T>, jest.Mock>>;

describe('ReportService', function () {
  let service: ReportService;
  let reportRepository: MockRepository<ReportEntity>;
  let postRepository: MockRepository<PostEntity>;
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReportService,
        {
          provide: getRepositoryToken(ReportEntity),
          useValue: mockReportRepository(),
        },
        {
          provide: getRepositoryToken(PostEntity),
          useValue: mockPostRepository(),
        },
      ],
    }).compile();

    service = module.get<ReportService>(ReportService);
    reportRepository = module.get<MockRepository<ReportEntity>>(
      getRepositoryToken(ReportEntity),
    );
    postRepository = module.get<MockRepository<PostEntity>>(
      getRepositoryToken(PostEntity),
    );
  });
  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createReport()', function () {
    const body = new CreateReportDto();
    body.post_id = 123;
    body.user_id = 'user';
    body.description = 'test';
    it('should bad request', function () {
      expect(async () => {
        await service.createReport(body, 'user');
      }).rejects.toThrowError(
        new HttpException('자신의 게시글은 신고 할 수 없습니다.', 400),
      );
    });

    it('should not found', function () {
      postRepository.exist.mockResolvedValue(false);
      expect(async () => {
        await service.createReport(body, 'user1');
      }).rejects.toThrowError(
        new HttpException('신고할 대상이 존재 하지 않습니다.', 404),
      );
    });

    it('should save', async function () {
      postRepository.exist.mockResolvedValue(true);
      await service.createReport(body, 'user1');
      expect(reportRepository.save).toHaveBeenCalledTimes(1);
    });
  });
});
