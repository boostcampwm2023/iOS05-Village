import * as crypto from 'crypto';

export const hashMaker = (nickname: string) => {
  return crypto
    .createHash('sha256')
    .update(nickname + new Date().getTime())
    .digest('base64');
};
