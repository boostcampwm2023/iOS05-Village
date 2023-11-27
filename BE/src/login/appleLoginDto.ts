import { IsString } from 'class-validator';

export class AppleLoginDto {
  @IsString()
  identity_token: string;

  @IsString()
  authorization_code: string;
}
