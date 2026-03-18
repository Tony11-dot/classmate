import { ConsoleLogger, Injectable } from '@nestjs/common';

@Injectable()
export class JsonLogger extends ConsoleLogger {
  private emit(level: string, message: unknown, context?: string, extra?: Record<string, unknown>) {
    const payload = {
      ts: new Date().toISOString(),
      level,
      context: context || this.context,
      message,
      ...extra,
    };
    process.stdout.write(`${JSON.stringify(payload)}\n`);
  }

  log(message: unknown, context?: string) {
    this.emit('info', message, context);
  }

  error(message: unknown, stack?: string, context?: string) {
    this.emit('error', message, context, { stack });
  }

  warn(message: unknown, context?: string) {
    this.emit('warn', message, context);
  }

  debug(message: unknown, context?: string) {
    this.emit('debug', message, context);
  }

  verbose(message: unknown, context?: string) {
    this.emit('verbose', message, context);
  }
}
