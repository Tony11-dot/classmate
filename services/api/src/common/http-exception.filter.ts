import { ArgumentsHost, Catch, ExceptionFilter, HttpException, HttpStatus } from '@nestjs/common';
import type { Request, Response } from 'express';
import { Sentry } from '../instrument';

/// The status carried by a non-Nest error that already knows its own HTTP code.
///
/// Express middleware registered with `app.use()` — the body parser above all —
/// throws `http-errors` objects, which are NOT `HttpException`s. Reading only
/// `HttpException` turned every one of them into a 500: a phone that hung up
/// halfway through uploading a notebook produced `BadRequestError: request
/// aborted`, which is a client disconnect and a 400, and we reported it to
/// Sentry as a server fault and told the client the server had crashed.
function httpErrorStatus(exception: unknown): number | undefined {
  const raw = (exception as any)?.status ?? (exception as any)?.statusCode;
  const status = typeof raw === 'number' ? raw : undefined;
  if (status === undefined) return undefined;
  return status >= 400 && status <= 599 ? status : undefined;
}

function describe(exception: unknown) {
  return {
    name:
      (exception as any)?.name ??
      (exception as any)?.constructor?.name ??
      'Error',
    message: (exception as any)?.message ?? String(exception),
  };
}

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
      : httpErrorStatus(exception) ?? HttpStatus.INTERNAL_SERVER_ERROR;

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

    // If the RESPONSE can no longer be written — the client hung up mid-request
    // (its socket is destroyed) or we've already responded — recording the error
    // for the access log is all we can do; writing would throw
    // ERR_STREAM_WRITE_AFTER_END on top of the original error.
    //
    // Guard on the RESPONSE stream, NOT `req.destroyed`. Under Express 5 the
    // request's readable side is destroyed the instant its body is fully
    // consumed, so a normally-completed POST reaches this filter with
    // `req.destroyed === true` even though its response socket is perfectly
    // writable. The earlier `req.destroyed` check therefore silently dropped the
    // response for EVERY errored POST-with-body — every failed login, every
    // validation 4xx — leaving the client to hang until its own timeout.
    // `res.destroyed` / `res.writableEnded` / `res.headersSent` are the correct
    // "can I still send a response?" signals (they also cover the real
    // hung-up-mid-upload case, where the shared socket — and thus res — is gone).
    if (res.headersSent || res.writableEnded || res.destroyed) {
      res.locals.error = describe(exception);
      return;
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

    res.locals.error = describe(exception);

    try {
      res.status(status).json({
        statusCode: status,
        path: req.originalUrl,
        method: req.method,
        requestId,
        ...payload,
      });
    } catch {
      // The socket vanished in the race between the guard above and this write
      // (a genuine client abort). The error is already recorded in
      // res.locals.error for the access log; there is nothing left to send.
    }
  }
}
