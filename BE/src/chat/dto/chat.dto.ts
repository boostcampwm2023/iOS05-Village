import { IsString } from 'class-validator';

export class ChatDto {
  @IsString()
  sender: string;

  @IsString()
  message: string;

  @IsString()
  room_id: number;
}
