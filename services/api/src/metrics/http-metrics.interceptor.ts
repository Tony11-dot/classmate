import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { finalize } from 'rxjs/operators';
import { Counter, Histogram, register } from 'prom-client';

const httpRequestsTotal =
  (register.getSingleMetric('http_requests_total') as Counter<string>) ||
  new Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status_code'],
  });

const httpRequestDurationSeconds =
  (register.getSingleMetric(
    'http_request_duration_seconds',
  ) as Histogram<string>) ||
  new Histogram({
    name: 'http_request_duration_seconds',
    help: 'HTTP request duration in seconds',
    labelNames: ['method', 'route', 'status_code'],
    buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
  });

@Injectable()
export class PrometheusHttpMetricsInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const http = context.switchToHttp();
    const req = http.getRequest<any>();
    const res = http.getResponse<any>();

    const start = process.hrtime.bigint();
    const method = (req?.method || 'UNKNOWN').toUpperCase();

    // Prefer Express route template to avoid high-cardinality URLs
    const route =
      req?.route?.path || req?.routerPath || req?.path || req?.url || 'unknown';

    return next.handle().pipe(
      finalize(() => {
        const end = process.hrtime.bigint();
        const seconds = Number(end - start) / 1e9;

        const statusCode = String(res?.statusCode ?? 0);

        httpRequestsTotal.labels(method, route, statusCode).inc(1);
        httpRequestDurationSeconds
          .labels(method, route, statusCode)
          .observe(seconds);
      }),
    );
  }
}
