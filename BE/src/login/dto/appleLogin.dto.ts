import { IsString } from 'class-validator';

export class AppleLoginDto {
  @IsString()
  authorization_code: string;

  @IsString()
  identity_token: string;

  @IsString()
  registration_token: string;
}
