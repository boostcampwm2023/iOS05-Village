import * as path from 'path';
import axios from 'axios';
import { uuid } from 'uuidv4';
import { ConfigService } from '@nestjs/config';
import { Injectable } from '@nestjs/common';

@Injectable()
export class OcrHandler {
  constructor(private configService: ConfigService) {}
  async convertImageToText(file: Express.Multer.File): Promise<string> {
    const res = await this.sendOcrRequest(file);
    let text;
    if (res.status === 200) {
      text = this.parseTextFromOcr(res.data.images[0].fields);
      return text;
    } else {
      return null;
    }
  }
  parseTextFromOcr(fields: Array<object>): string {
    let text: string = '';
    for (let i = 0; i < fields.length; i++) {
      text += fields[i]['inferText'] + ' ';
      if (fields[i]['lineBreak'] === true) text += '\n';
    }
    return text;
  }

  async sendOcrRequest(file: Express.Multer.File) {
    const imgInfo = path.parse(file.originalname);
    const imgBuffer = file.buffer;
    return await axios.post(
      this.configService.get('CLOVA_URL'), // APIGW Invoke URL
      {
        images: [
          {
            format: imgInfo.ext.slice(1), // file format
            name: imgInfo.name, // image name
            data: imgBuffer.toString('base64'), // image base64 string(only need part of data). Example: base64String.split(',')[1]
          },
        ],
        requestId: uuid(), // unique string
        timestamp: 0,
        version: 'V2',
      },
      {
        headers: {
          'X-OCR-SECRET': this.configService.get('CLOVA_SECRET'), // Secret Key
        },
      },
    );
  }
}
