import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';

@Catch()
export class LogExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const req = ctx.getRequest();
    const res = ctx.getResponse();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const payload =
      exception instanceof HttpException
        ? exception.getResponse()
        : { statusCode: status, message: 'Internal server error' };

    // Always log stack + context
    // eslint-disable-next-line no-console
    console.error('[EXCEPTION]', {
      method: req?.method,
      url: req?.url,
      status,
      requestId: req?.id,
      message: (exception as any)?.message,
      stack: (exception as any)?.stack,
      payload,
    });

    if (!res.headersSent) {
      res.status(status).json(typeof payload === 'string' ? { statusCode: status, message: payload } : payload);
    }
  }
}
