import {
  ArgumentMetadata,
  BadRequestException,
  Injectable,
  PipeTransform,
} from '@nestjs/common';

@Injectable()
export class FilesSizeValidator implements PipeTransform {
  transform(value: any, metadata: ArgumentMetadata): any {
    if (value.length === 0) {
      return value;
    }
    const maxSize = 1024 * 1024 * 20;
    const files: Express.Multer.File[] = value;
    for (const file of files) {
      if (file.size > maxSize) {
        throw new BadRequestException(
          `File ${file.originalname} exceeds the allowed size limit`,
        );
      }
    }
    return value;
  }
}

export class FileSizeValidator implements PipeTransform {
  transform(value: any, metadata: ArgumentMetadata): any {
    if (value === undefined) {
      return value;
    }
    const maxSize = 1024 * 1024 * 20;
    const file: Express.Multer.File = value;
    if (file.size > maxSize) {
      throw new BadRequestException(
        `File ${file.originalname} exceeds the allowed size limit`,
      );
    }
    return value;
  }
}
