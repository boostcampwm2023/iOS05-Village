import * as winston from 'winston';
import {
  utilities as nestWinstonModuleUtilities,
  utilities,
  WinstonModule,
} from 'nest-winston';
import * as winstonDaily from 'winston-daily-rotate-file';

export const winstonOptions = new winston.transports.Console({
  level: process.env.NODE_ENV === 'prod' ? 'http' : 'silly',
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

export const winstonTransportsOption = [
  winstonOptions,
  new winstonDaily(dailyOption('error')),
  new winstonDaily(dailyOption('warn')),
  new winstonDaily(dailyOption('info')),
  new winstonDaily(dailyOption('debug')),
];

export const winstonLogger = WinstonModule.createLogger({
  transports: winstonTransportsOption,
});
