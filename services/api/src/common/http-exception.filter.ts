import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import type { Request, Response } from 'express';
import { Sentry } from '../instrument';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const req = ctx.getRequest<Request>();
    const res = ctx.getResponse<Response>();

    const requestId =
      (req.headers['x-request-id'] as string | undefined) ||
      (req as any).requestId ||
      undefined;

    const isHttp = exception instanceof HttpException;
    const status = isHttp
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const base =
      isHttp ? exception.getResponse() : { message: 'Internal server error' };

    const payload =
      typeof base === 'string'
        ? { message: base }
        : (base as Record<string, any>);

    // Report real server-side faults (5xx) to Sentry — these are the actual
    // bugs. Client errors (4xx: bad input, auth, 404, 402 out-of-tokens,
    // 409 duplicate-book, etc.) are expected and would just be noise.
    // No-ops when Sentry isn't initialised (no SENTRY_DSN).
    if (status >= 500) {
      Sentry.withScope((scope) => {
        scope.setTag('path', req.originalUrl);
        scope.setTag('method', req.method);
        if (requestId) scope.setTag('request_id', String(requestId));
        Sentry.captureException(exception);
      });
    }

    if (requestId) res.setHeader('x-request-id', requestId);

    if (process.env.NODE_ENV === 'test') {
      // eslint-disable-next-line no-console
      if (process.env.LOG_EXCEPTIONS === '1') {
        // eslint-disable-next-line no-console
        console.log(
          'EXC',
          (exception as any)?.name ?? (exception as any)?.constructor?.name ?? 'Error',
          (exception as any)?.message ?? String(exception),
        );
      }
    }

    res.locals.error = {
      name: (exception as any)?.name ?? (exception as any)?.constructor?.name ?? "Error",
      message: (exception as any)?.message ?? String(exception),
    };

    res.status(status).json({
      statusCode: status,
      path: req.originalUrl,
      method: req.method,
      requestId,
      ...payload,
    });
  }
}
