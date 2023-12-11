import axios from 'axios';
import { uuid } from 'uuidv4';
import { ConfigService } from '@nestjs/config';
import { Injectable } from '@nestjs/common';

@Injectable()
export class GreenEyeHandler {
  constructor(private configService: ConfigService) {}
  async isHarmful(fileLocation: string): Promise<boolean> {
    const response = await this.sendGreenEyeRequest(fileLocation);
    const normalResult = response.data.images[0].result.normal.confidence;
    return normalResult < 0.8;
  }

  async sendGreenEyeRequest(url: string) {
    return await axios.post(
      this.configService.get('CLOVA_URL'),
      {
        images: [
          {
            name: 'file',
            url: url,
          },
        ],
        requestId: uuid(),
        timestamp: 0,
        version: 'V1',
      },
      {
        headers: {
          'X-GREEN-EYE-SECRET': this.configService.get('CLOVA_SECRET'),
        },
      },
    );
  }
}
