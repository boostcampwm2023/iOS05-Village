import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Delete,
  UseInterceptors,
  ValidationPipe,
  UploadedFile,
  HttpException,
  UseGuards,
  Body,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './createUser.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { MultiPartBody } from 'src/utils/multiPartBody.decorator';
import { UpdateUsersDto } from './usersUpdate.dto';
import { AuthGuard } from 'src/utils/auth.guard';
import { UserHash } from '../utils/auth.decorator';

@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get(':id')
  async usersDetails(@Param('id') userId) {
    const user = await this.usersService.findUserById(userId);
    if (user === null) {
      throw new HttpException('유저가 존재하지않습니다.', 404);
    } else {
      return user;
    }
  }

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
  async usersRemove(@Param('id') id: string, @UserHash() userId) {
    await this.usersService.removeUser(id, userId);
  }

  @Patch(':id')
  @UseInterceptors(FileInterceptor('image'))
  async usersModify(
    @Param('id') id: string,
    @MultiPartBody('profile') body: UpdateUsersDto,
    @UploadedFile() file: Express.Multer.File,
    @UserHash() userId,
  ) {
    await this.usersService.updateUserById(id, body, file, userId);
  }

  @Post('registration-token')
  async registrationTokenSave(
    @Body('registration_token') registrationToken: string,
    @UserHash() userId: string,
  ) {
    await this.usersService.registerToken(userId, registrationToken);
  }
}
