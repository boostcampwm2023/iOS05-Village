import { IsString } from 'class-validator';

export class CreateUserDto {
  @IsString()
  nickname: string;

  @IsString()
  social_email: string;

  @IsString()
  OAuth_domain: string;
}
