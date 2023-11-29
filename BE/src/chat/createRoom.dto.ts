import { IsNumber, IsString } from 'class-validator';

export class CreateRoomDto {
  @IsNumber()
  post_id: number;
  @IsString()
  writer: string;
}
