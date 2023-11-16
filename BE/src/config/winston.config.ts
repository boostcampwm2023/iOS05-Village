import * as winston from 'winston';
import {
  utilities as nestWinstonModuleUtilities,
  utilities,
} from 'nest-winston';

export const winstonOptions = new winston.transports.Console({
  level: process.env.NODE_ENV === 'prod' ? 'info' : 'silly',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.colorize({ all: true }),
    nestWinstonModuleUtilities.format.nestLike('Village', {
      prettyPrint: true,
    }),
  ),
});

export const dailyOption = (level: string) => {
  return {
    level,
    datePattern: 'YYYY-MM-DD',
    dirname: `./logs/${level}`,
    filename: `%DATE%.${level}.log`,
    maxFiles: 30,
    zippedArchive: true,
    format: winston.format.combine(
      winston.format.timestamp(),
      utilities.format.nestLike(process.env.NODE_ENV, {
        colors: false,
        prettyPrint: true,
      }),
    ),
  };
};
