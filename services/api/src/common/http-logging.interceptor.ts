import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class HttpLoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  private getTcpPeer(req: any): string {
    const ra =
      (req?.socket?.remoteAddress as string | undefined) ||
      (req?.connection?.remoteAddress as string | undefined) ||
      '';
    return (ra || '').replace(/^::ffff:/, '') || 'unknown';
  }

  private getForwardedIp(req: any): string {
    const xff = (req?.headers?.['x-forwarded-for'] as string | undefined) || '';
    const xri = (req?.headers?.['x-real-ip'] as string | undefined) || '';
    return (xff || xri || '').toString();
  }

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const http = context.switchToHttp();
    const req = http.getRequest<Request>();
    const res = http.getResponse<Response>();

    const start = Date.now();
    const requestId =
      (req as any).requestId || req.header('x-request-id') || 'unknown';

    const method = req.method;
    const url = (req as any).originalUrl || req.url;
    const tcpPeer = this.getTcpPeer(req);
    const effectiveIp = tcpPeer;
    const xff = (req?.headers?.['x-forwarded-for'] as string | undefined) || '';
    const xri = (req?.headers?.['x-real-ip'] as string | undefined) || '';
    const forwardedIp = (xff || xri || '').toString();
    const ip = effectiveIp;

    return next.handle().pipe(
      tap({
        next: () => {
          const ms = Date.now() - start;
          this.logger.log(
            JSON.stringify({
              requestId,
              method,
              url,
              status: res.statusCode,
              ms,
              effectiveIp,
              forwardedIp,
              xff,
              xri,
              ip,
              tcpPeer,
            }),
          );
        },
        error: (err) => {
          const ms = Date.now() - start;
          this.logger.error(
            JSON.stringify({
              requestId,
              method,
              url,
              status: res.statusCode,
              ms,
              effectiveIp,
              forwardedIp,
              xff,
              xri,
              ip,
              tcpPeer,

              error: {
                name: err?.name,
                message: err?.message,
              },
            }),
          );
        },
      }),
    );
  }
}
