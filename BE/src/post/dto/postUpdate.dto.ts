import { IsArray, IsNumber, IsOptional, IsString } from 'class-validator';

export class UpdatePostDto {
  @IsOptional() // 이 필드는 선택적으로 업데이트할 수 있도록 설정
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  contents?: string;

  @IsOptional()
  @IsNumber() // 전화번호 형식 검증
  price?: number;

}
