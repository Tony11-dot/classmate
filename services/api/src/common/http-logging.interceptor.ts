import {
  CallHandler,
  ExecutionContext,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { Observable } from 'rxjs';

@Injectable()
export class HttpLoggingInterceptor implements NestInterceptor {
  private readonly log = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const http = context.switchToHttp();
    const req = http.getRequest<Request>();
    const res = http.getResponse<Response>();

    const start = Date.now();

    const requestId =
      (req.headers['x-request-id'] as string | undefined) ||
      (req as any).requestId ||
      undefined;

    // capture final status code AFTER response is sent
    if (!(res as any).__cm_http_logged) {
      (res as any).__cm_http_logged = true;

      res.once('finish', () => {
        const ms = Date.now() - start;

        const effectiveIp =
          (req.headers['cf-connecting-ip'] as string | undefined) ||
          (req.headers['x-real-ip'] as string | undefined) ||
          (req.headers['x-forwarded-for'] as string | undefined)?.split(',')[0]?.trim() ||
          req.ip;

        const forwardedIp = (req.headers['x-forwarded-for'] as string | undefined) || '';
        const xff = (req.headers['x-forwarded-for'] as string | undefined) || '';
        const xri = (req.headers['x-real-ip'] as string | undefined) || '';

        const status = res.statusCode;

        const payload: any = {
          requestId,
          method: req.method,
          url: req.originalUrl,
          status,
          ms,
          effectiveIp,
          forwardedIp,
          xff,
          xri,
          ip: req.ip,
          tcpPeer: (req.socket as any)?.remoteAddress ?? '',
        };

        // if an exception filter attached a name/message onto res.locals, include it
        const err = (res.locals as any)?.error;
        if (err) payload.error = err;

        if (status >= 500) this.log.error(payload);
        else if (status >= 400) this.log.warn(payload);
        else this.log.log(payload);
      });
    }

    return next.handle();
  }
}
