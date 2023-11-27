import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from '../entities/user.entity';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { AppleLoginDto } from './appleLoginDto';
import { hashMaker } from '../utils/hashMaker';

export interface SocialProperties {
  OAuthDomain: string;
  socialId: string;
}

export interface JwtTokens {
  access_token: string;
  refresh_token: string;
}

@Injectable()
export class LoginService {
  constructor(
    private jwtService: JwtService,
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    private configService: ConfigService,
  ) {}
  async login(socialProperties: SocialProperties): Promise<JwtTokens> {
    let user: UserEntity = await this.VerifyUserRegistration(socialProperties);
    if (!user) {
      user = await this.registerUser(socialProperties);
    }
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);
    return { access_token: accessToken, refresh_token: refreshToken };
  }

  async registerUser(socialProperties: SocialProperties) {
    const userEntity = new UserEntity();
    userEntity.nickname = this.generateRandomString(8);
    userEntity.social_id = socialProperties.socialId;
    userEntity.OAuth_domain = socialProperties.OAuthDomain;
    userEntity.profile_img = null;
    userEntity.user_hash = hashMaker(userEntity.nickname).slice(0, 8);
    return await this.userRepository.save(userEntity);
  }

  generateRandomString(length) {
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    const charsetLength = charset.length;

    for (let i = 0; i < length; i++) {
      const randomIndex = Math.floor(Math.random() * charsetLength);
      result += charset[randomIndex];
    }

    return result;
  }

  async VerifyUserRegistration(
    socialProperties: SocialProperties,
  ): Promise<UserEntity> {
    const user = await this.userRepository.findOne({
      where: {
        OAuth_domain: socialProperties.OAuthDomain,
        social_id: socialProperties.socialId,
      },
    });
    return user;
  }

  generateAccessToken(user: UserEntity): string {
    return this.jwtService.sign({
      userId: user.user_hash,
      nickname: user.nickname,
    });
  }

  generateRefreshToken(user: UserEntity): string {
    return this.jwtService.sign(
      {
        userId: user.user_hash,
      },
      {
        secret: this.configService.get('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN'),
      },
    );
  }

  async appleOAuth(body: AppleLoginDto): Promise<SocialProperties> {
    return null;
  }
}
