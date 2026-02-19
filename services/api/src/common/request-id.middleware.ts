import { Injectable, NestMiddleware } from '@nestjs/common';
import type { Request, Response, NextFunction } from 'express';
import { randomUUID } from 'crypto';

@Injectable()
export class RequestIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const incoming = req.header('x-request-id');
    const id = (incoming && String(incoming).trim()) || randomUUID();

    (req as any).requestId = id;
    res.setHeader('x-request-id', id);

    next();
  }
}
