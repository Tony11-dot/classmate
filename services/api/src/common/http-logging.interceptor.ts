import {
  CallHandler,
  ExecutionContext,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class HttpLoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const http = context.switchToHttp();
    const req = http.getRequest<Request & { requestId?: string }>();
    const res = http.getResponse<Response>();

    const start = Date.now();

    const requestId =
      (req as any)?.requestId ??
      String(req.headers['x-request-id'] ?? req.headers['x-amzn-trace-id'] ?? '');

    const forwardedIp = String(req.headers['x-forwarded-for'] ?? '');
    const xff = forwardedIp;
    const xri = String(req.headers['x-real-ip'] ?? '');
    const ip = String((req as any)?.ip ?? '');
    const effectiveIp = xri || (xff ? String(xff).split(',')[0].trim() : '') || ip;

    const url = (req as any)?.originalUrl || req.url;

    let errForLog: any = null;
    let logged = false;

    const logOnce = () => {
      if (logged) return;
      logged = true;

      const ms = Date.now() - start;
      const status = res.statusCode;

      const payload: any = {
        requestId,
        method: req.method,
        url,
        status,
        ms,
        effectiveIp,
        forwardedIp,
        xff,
        xri,
        ip,
        tcpPeer: String((req.socket as any)?.remoteAddress ?? ''),
      };

      if (errForLog) {
        payload.error = {
          name: String(errForLog?.name ?? 'Error'),
          message: String(errForLog?.message ?? ''),
        };
        this.logger.error(JSON.stringify(payload));
        return;
      }

      this.logger.log(JSON.stringify(payload));
    };

    // 'finish' fires after Nest exception filters set the final status code
    res.once('finish', logOnce);
    // fallback (client abort)
    res.once('close', logOnce);

    return next.handle().pipe(
      tap({
        error: (err) => {
          errForLog = err;
        },
      }),
    );
  }
}
