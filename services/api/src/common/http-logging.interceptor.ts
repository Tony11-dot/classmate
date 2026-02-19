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

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const http = context.switchToHttp();
    const req = http.getRequest<Request>();
    const res = http.getResponse<Response>();

    const start = Date.now();
    const requestId =
      (req as any).requestId || req.header('x-request-id') || 'unknown';

    const method = req.method;
    const url = (req as any).originalUrl || req.url;
    const ip =
      (req.headers['x-forwarded-for'] as string) ||
      (req.socket && req.socket.remoteAddress) ||
      '';

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
              ip,
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
              ip,
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
