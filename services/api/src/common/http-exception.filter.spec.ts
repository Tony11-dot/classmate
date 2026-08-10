import { BadRequestException, HttpStatus } from '@nestjs/common';
import { HttpExceptionFilter } from './http-exception.filter';

/// A stand-in for the Express request/response pair the filter is handed.
function host(req: Record<string, unknown> = {}, res: Record<string, unknown> = {}) {
  const response = {
    statusCode: 0,
    body: undefined as unknown,
    headersSent: false,
    locals: {} as Record<string, unknown>,
    setHeader: jest.fn(),
    status(code: number) {
      this.statusCode = code;
      return this;
    },
    json(payload: unknown) {
      this.body = payload;
      return this;
    },
    ...res,
  };
  const request = {
    headers: {},
    originalUrl: '/classnotes/notebooks/abc',
    method: 'PUT',
    destroyed: false,
    ...req,
  };
  return {
    response,
    host: {
      switchToHttp: () => ({
        getRequest: () => request,
        getResponse: () => response,
      }),
    } as never,
  };
}

/// `raw-body` throws this when the client hangs up mid-upload. It is an
/// `http-errors` object, NOT a Nest `HttpException`.
function abortedBodyError() {
  const error = new Error('request aborted') as Error & {
    status: number;
    statusCode: number;
    expose: boolean;
  };
  error.name = 'BadRequestError';
  error.status = 400;
  error.statusCode = 400;
  error.expose = true;
  return error;
}

describe('HttpExceptionFilter', () => {
  const filter = new HttpExceptionFilter();

  it('keeps an http-errors status instead of calling it a server fault', () => {
    // The bug: only `HttpException` was recognised, so every error thrown by
    // Express middleware — the body parser above all — became a 500. A phone
    // that backgrounded halfway through uploading a notebook produced
    // "BadRequestError: request aborted", and we reported a client disconnect
    // to Sentry as a crash and told the client the server had fallen over.
    const { host: ctx, response } = host();
    filter.catch(abortedBodyError(), ctx);
    expect(response.statusCode).toBe(400);
    expect(response.locals.error).toEqual({
      name: 'BadRequestError',
      message: 'request aborted',
    });
  });

  it('does not try to answer a socket the client already closed', () => {
    const { host: ctx, response } = host({ destroyed: true });
    filter.catch(abortedBodyError(), ctx);
    // Writing to a destroyed socket throws ERR_STREAM_WRITE_AFTER_END on top
    // of the original error; the access log still gets the reason.
    expect(response.statusCode).toBe(0);
    expect(response.body).toBeUndefined();
    expect(response.locals.error).toMatchObject({ message: 'request aborted' });
  });

  it('still reports a genuine fault as a 500', () => {
    const { host: ctx, response } = host();
    filter.catch(new Error('kaboom'), ctx);
    expect(response.statusCode).toBe(HttpStatus.INTERNAL_SERVER_ERROR);
  });

  it('leaves Nest exceptions exactly as they were', () => {
    const { host: ctx, response } = host();
    filter.catch(new BadRequestException('nope'), ctx);
    expect(response.statusCode).toBe(400);
    expect(response.body).toMatchObject({ statusCode: 400, message: 'nope' });
  });

  it('ignores a nonsense status rather than trusting it', () => {
    const weird = new Error('odd') as Error & { status: number };
    weird.status = 999;
    const { host: ctx, response } = host();
    filter.catch(weird, ctx);
    expect(response.statusCode).toBe(HttpStatus.INTERNAL_SERVER_ERROR);
  });
});
