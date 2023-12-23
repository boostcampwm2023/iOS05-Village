import { IsNumber, IsOptional, IsString } from 'class-validator';
import { Type } from 'class-transformer';

export class PostListDto {
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  cursorId: number;

  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  requestFilter: number;

  @IsString()
  @IsOptional()
  searchKeyword: string;

  @IsString()
  @IsOptional()
  writer: string;
}
