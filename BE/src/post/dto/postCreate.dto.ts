import { IsBoolean, IsNumber, IsString, ValidateIf } from 'class-validator';

export class PostCreateDto {
  @IsString()
  title: string;

  @IsString()
  contents: string;

  @IsNumber()
  @ValidateIf((object) => object.is_request === false)
  price: number;

  @IsBoolean()
  is_request: boolean;

  @IsString()
  start_date: string;

  @IsString()
  end_date: string;
}
