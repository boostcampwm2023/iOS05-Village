import { IsBoolean, IsNumber, IsString, ValidateIf } from 'class-validator';

export class CreatePostDto {
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
