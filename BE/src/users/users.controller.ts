import {
  Controller,
  Get,
  Post,
  Patch,
  Param,
  Delete,
  UseInterceptors,
  UploadedFile,
  HttpException,
  UseGuards,
  Body,
  Headers,
} from '@nestjs/common';
import { UsersService } from './users.service';
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

  @Delete(':id')
  @UseInterceptors(TransactionInterceptor)
  async usersRemove(
    @Param('id') id: string,
    @UserHash() userId: string,
    @Headers('authorization') token: string,
  ) {
    await this.usersService.checkAuth(id, userId);
    await this.usersService.removeUser(userId, token);
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
    await this.usersService.updateUserById(nickname, imageLocation, userId);
  }

  @Post('registration-token')
  async registrationTokenSave(
    @Body('registration_token') registrationToken: string,
    @UserHash() userId: string,
  ) {
    await this.notificationService.registerToken(userId, registrationToken);
  }
}
