import { IsBoolean, IsString, MaxLength } from 'class-validator';
import { IsPriceCorrect } from '../../utils/price.decorator';

export class PostCreateDto {
  @IsString()
  @MaxLength(100)
  title: string;

  @IsString()
  contents: string;

  @IsPriceCorrect('is_request')
  price: number;

  @IsBoolean()
  is_request: boolean;

  @IsString()
  start_date: string;

  @IsString()
  end_date: string;
}
