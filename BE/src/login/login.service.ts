import { HttpException, Inject, Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from '../entities/user.entity';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { hashMaker } from '../common/hashMaker';
import { AppleLoginDto } from './dto/appleLogin.dto';
import * as jwt from 'jsonwebtoken';
import * as jwksClient from 'jwks-rsa';
import { FcmHandler } from '../common/fcmHandler';
import { CACHE_MANAGER, CacheStore } from '@nestjs/cache-manager';

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
  private jwksClient: jwksClient.JwksClient;
  private readonly logger = new Logger('Login');
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    private configService: ConfigService,
    private jwtService: JwtService,
    private fcmHandler: FcmHandler,
    @Inject(CACHE_MANAGER) private cacheManager: CacheStore,
  ) {
    this.jwksClient = jwksClient({
      jwksUri: 'https://appleid.apple.com/auth/keys',
    });
  }
  async login(socialProperties: SocialProperties): Promise<JwtTokens> {
    let user: UserEntity = await this.verifyUserRegistration(socialProperties);
    if (!user) {
      user = await this.registerUser(socialProperties);
    }
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);
    await this.cacheManager.set(
      user.user_hash,
      refreshToken,
      this.configService.get('JWT_REFRESH_EXPIRES_IN'),
    );
    this.logger.log(`${user.user_hash} login`);
    return { access_token: accessToken, refresh_token: refreshToken };
  }

  async logout(accessToken) {
    const decodedToken: any = jwt.decode(accessToken);
    if (decodedToken && decodedToken.exp) {
      await this.fcmHandler.removeRegistrationToken(decodedToken.userId);
      const ttl: number = decodedToken.exp - Math.floor(Date.now() / 1000);
      await this.cacheManager.set(accessToken, 'logout', { ttl });
      await this.cacheManager.del(decodedToken.userId);
      this.logger.log(`${decodedToken.userId} logout`);
    }
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

  async verifyUserRegistration(
    socialProperties: SocialProperties,
  ): Promise<UserEntity> {
    return await this.userRepository.findOne({
      where: {
        OAuth_domain: socialProperties.OAuthDomain,
        social_id: socialProperties.socialId,
      },
    });
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

  decodeIdentityToken(identityToken: string) {
    const identityTokenParts = identityToken.split('.');
    const identityTokenPayload = identityTokenParts[1];

    return Buffer.from(identityTokenPayload, 'base64').toString();
  }

  async getApplePublicKey(kid: string) {
    const client = jwksClient({
      jwksUri: 'https://appleid.apple.com/auth/keys',
    });

    const key = await client.getSigningKey(kid);
    return key.getPublicKey();
  }

  async appleOAuth(body: AppleLoginDto): Promise<SocialProperties> {
    const payloadClaims = this.decodeIdentityToken(body.identity_token); // 토큰을 디코딩해서 페이로드를 가져옴
    const payloadClaimsJson = JSON.parse(payloadClaims);

    const kid = this.getkid(body.identity_token); // 토큰을 디코딩해서 kid를 가져옴
    const applePublicKey = await this.getApplePublicKey(kid);

    const isVerified: any = jwt.verify(body.identity_token, applePublicKey);

    if (isVerified) {
      return { OAuthDomain: 'apple', socialId: payloadClaimsJson.sub };
    } else {
      return null;
    }
  }

  getkid(identityToken: string) {
    const identityTokenParts = identityToken.split('.');
    const identityTokenHeader = identityTokenParts[0];

    const headerClaims = Buffer.from(identityTokenHeader, 'base64').toString();

    const headerClaimsJson = JSON.parse(headerClaims);

    return headerClaimsJson.kid;
  }

  validateToken(token: string, kind: 'access' | 'refresh') {
    const secret = kind === 'access' ? 'JWT_SECRET' : 'JWT_REFRESH_SECRET';
    return this.jwtService.verify(token, {
      secret: this.configService.get(secret),
    });
  }

  async refreshToken(refreshtoken, payload): Promise<JwtTokens> {
    const user = await this.userRepository.findOne({
      where: { user_hash: payload.userId },
    });

    if ((await this.cacheManager.get(user.user_hash)) === refreshtoken) {
      const accessToken = this.generateAccessToken(user);
      const refreshToken = this.generateRefreshToken(user);
      await this.cacheManager.set(
        user.user_hash,
        refreshToken,
        this.configService.get('JWT_REFRESH_EXPIRES_IN'),
      );
      return { access_token: accessToken, refresh_token: refreshToken };
    } else {
      throw new HttpException('refresh token이 유효하지 않음', 401);
    }
  }

  async loginAdmin(id) {
    const user = await this.userRepository.findOne({
      where: { user_hash: id },
    });
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);
    await this.cacheManager.set(
      user.user_hash,
      refreshToken,
      this.configService.get('JWT_REFRESH_EXPIRES_IN'),
    );
    return { access_token: accessToken, refresh_token: refreshToken };
  }
}
