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
  Headers,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/createUser.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { MultiPartBody } from 'src/common/decorator/multiPartBody.decorator';
import { UpdateUsersDto } from './dto/usersUpdate.dto';
import { AuthGuard } from 'src/common/guard/auth.guard';
import { UserHash } from '../common/decorator/auth.decorator';
import { FileSizeValidator } from '../common/files.validator';
import { ImageService } from '../image/image.service';
import { NotificationService } from '../notification/notification.service';
import { TransactionInterceptor } from '../common/interceptor/transaction.interceptor';

@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(
    private readonly usersService: UsersService,
    private readonly imageService: ImageService,
    private readonly notificationService: NotificationService,
  ) {}

  @Get(':id')
  async usersDetails(@Param('id') userId) {
    const user = await this.usersService.findUserById(userId);
    if (user === null) {
      throw new HttpException('유저가 존재하지않습니다.', 404);
    } else {
      return user;
    }
  }

  // @Post()
  // @UseInterceptors(FileInterceptor('profileImage'))
  // async usersCreate(
  //   @UploadedFile(new FileSizeValidator())
  //   file: Express.Multer.File,
  //   @MultiPartBody(
  //     'profile',
  //     new ValidationPipe({ validateCustomDecorators: true }),
  //   )
  //   createUserDto: CreateUserDto,
  // ) {
  //   let imageLocation: string;
  //
  //   if (file !== undefined) {
  //     imageLocation = await this.usersService.uploadImages(file);
  //   }
  //   await this.usersService.createUser(imageLocation, createUserDto);
  // }

  @Delete(':id')
  @UseInterceptors(TransactionInterceptor)
  async usersRemove(
    @Param('id') id: string,
    @UserHash() userId: string,
    @Headers('authorization') token: string,
  ) {
    await this.usersService.checkAuth(id, userId);
    await this.usersService.removeUser(id, userId, token);
    await this.notificationService.removeRegistrationToken(userId);
  }

  @Patch(':id')
  @UseInterceptors(FileInterceptor('image'))
  async usersModify(
    @Param('id') id: string,
    @MultiPartBody('profile') body: UpdateUsersDto,
    @UploadedFile(new FileSizeValidator()) file: Express.Multer.File,
    @UserHash() userId,
  ) {
    await this.usersService.checkAuth(id, userId);
    const imageLocation = file
      ? await this.imageService.uploadImage(file)
      : null;
    const nickname = body ? body.nickname : null;
    await this.usersService.updateUserById(id, nickname, imageLocation, userId);
  }

  @Post('registration-token')
  async registrationTokenSave(
    @Body('registration_token') registrationToken: string,
    @UserHash() userId: string,
  ) {
    await this.notificationService.registerToken(userId, registrationToken);
  }
}
