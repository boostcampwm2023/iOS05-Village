import { ConfigService } from '@nestjs/config';
import { JwtModuleOptions, JwtOptionsFactory } from '@nestjs/jwt';
import { Injectable } from '@nestjs/common';

@Injectable()
export class JwtConfig implements JwtOptionsFactory {
  constructor(private configService: ConfigService) {}

  createJwtOptions(): JwtModuleOptions {
    const jwtModuleOptions: JwtModuleOptions = {
      secret: this.configService.get('JWT_SECRET'),
      signOptions: {
        expiresIn: this.configService.get('JWT_EXPIRES_IN'),
      },
    };
    return jwtModuleOptions;
  }
}
