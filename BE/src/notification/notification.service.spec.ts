import { Test, TestingModule } from '@nestjs/testing';
import { NotificationService } from './notification.service';
import { ConfigService } from '@nestjs/config';
import { RegistrationTokenRepository } from './registrationToken.repository';
import { RegistrationTokenEntity } from '../entities/registrationToken.entity';
import { PushMessage } from '../common/fcmHandler';

const mockRepository = {
  save: jest.fn(),
  delete: jest.fn(),
  findOne: jest.fn(),
  update: jest.fn(),
};

const mockAdmin = jest.requireMock('firebase-admin');
jest.mock('firebase-admin');
mockAdmin.apps = [];

describe('NotificationService', () => {
  let service: NotificationService;
  let repository;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationService,
        {
          provide: RegistrationTokenRepository,
          useValue: mockRepository,
        },
        {
          provide: ConfigService,
          useValue: { get: jest.fn((key: string) => 'mocked-value') },
        },
      ],
    }).compile();

    service = module.get<NotificationService>(NotificationService);
    repository = module.get(RegistrationTokenRepository);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getRegistrationToken', function () {
    it('should return null when token does not exist', async function () {
      repository.findOne.mockResolvedValue(null);
      const res = await service.getRegistrationToken('user');
      expect(res).toEqual(null);
    });

    it('should return registration token', async function () {
      const registrationToken = new RegistrationTokenEntity();
      registrationToken.registration_token = 'test';
      repository.findOne.mockResolvedValue(registrationToken);
      const res = await service.getRegistrationToken('user');
      expect(res).toEqual('test');
    });
  });

  describe('registerToken', function () {
    it('should create token', async function () {
      repository.findOne.mockResolvedValue(null);
      await service.registerToken('user', 'token');
      expect(repository.save).toHaveBeenCalled();
    });

    it('should update token', async function () {
      repository.findOne.mockResolvedValue(new RegistrationTokenEntity());
      await service.registerToken('user', 'token');
      expect(repository.update).toHaveBeenCalled();
    });
  });

  describe('removeRegistrationToken', function () {
    it('should remove', async function () {
      await service.removeRegistrationToken('userId');
      expect(repository.delete).toHaveBeenCalled();
    });
  });

  describe('createChatNotificationMessage', function () {
    it('should return message', function () {
      const pushMessage: PushMessage = {
        body: 'message',
        data: {
          room_id: '123',
        },
        title: 'nickname',
      };
      const result = service.createChatNotificationMessage(
        'token',
        pushMessage,
      );
      expect(result.token).toEqual('token');
      expect(result.notification.title).toEqual('nickname');
      expect(result.notification.body).toEqual('message');
      expect(result.data.room_id).toEqual('123');
    });
  });
});
