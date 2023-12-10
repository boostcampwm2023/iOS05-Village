import { IsNumber, IsString } from 'class-validator';

export class CreateReportDto {
  @IsString()
  description: string;

  @IsNumber()
  post_id: number;

  @IsString()
  user_id: string;
}
