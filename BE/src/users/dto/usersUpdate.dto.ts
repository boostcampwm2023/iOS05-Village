import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class UpdateUsersDto {
  @IsOptional() // 이 필드는 선택적으로 업데이트할 수 있도록 설정
  @IsString()
  nickname?: string;

  // @IsOptional() // 이 필드는 선택적으로 업데이트할 수 있도록 설정
  // @IsBoolean()
  // is_image_changed?: string;
}
