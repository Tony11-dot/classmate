import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { metrics } from '../metrics/metrics';

@Injectable()
export class RequestMetricsInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    const key = `${req?.method || 'UNKNOWN'} ${req?.route?.path || req?.url || 'unknown'}`;
    const started = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          metrics.inc(`http.requests.${key}`);
          metrics.observe(`http.latency.${key}`, Date.now() - started);
        },
        error: () => {
          metrics.inc(`http.errors.${key}`);
          metrics.observe(`http.latency.${key}`, Date.now() - started);
        },
      }),
    );
  }
}
