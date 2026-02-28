import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';

@Catch()
export class E2EDebugExceptionFilter implements ExceptionFilter {
  catch(exception: any, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse();
    const req = ctx.getRequest();

    const isTest = process.env.NODE_ENV === 'test' || process.env.E2E_DEBUG === '1';

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const message =
      exception instanceof HttpException
        ? (exception.getResponse() as any)
        : exception?.message || 'Internal server error';

    // Always log full exception server-side
    // eslint-disable-next-line no-console
    console.error('🔥 E2E DEBUG EXCEPTION:', exception);

    const body: any = {
      statusCode: status,
      path: req?.url,
      method: req?.method,
      message,
    };

    if (isTest) {
      body.stack = exception?.stack;
      body.name = exception?.name;
      body.cause = exception?.cause;
    }

    res.status(status).json(body);
  }
}
