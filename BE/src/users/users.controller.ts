import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseInterceptors,
  UploadedFiles,
  ValidationPipe,
  UploadedFile,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './createUser.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { MultiPartBody } from 'src/utils/multiPartBody.decorator';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @UseInterceptors(FileInterceptor('profileImage'))
  async usersCreate(
    @UploadedFile() file: Express.Multer.File,
    @MultiPartBody(
      'profile',
      new ValidationPipe({ validateCustomDecorators: true }),
    )
    createUserDto: CreateUserDto,
  ) {
    let imageLocation: string;

    if (file !== undefined) {
      imageLocation = await this.usersService.uploadImages(file);
    }
    await this.usersService.createUser(imageLocation, createUserDto);
  }

  @Delete(':id')
  usersRemove(@Param('id') id: string) {
    return this.usersService.removeUser(+id);
  }
}
