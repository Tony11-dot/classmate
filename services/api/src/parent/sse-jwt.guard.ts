import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class SseJwtGuard extends AuthGuard('jwt') {
  // EventSource can't set Authorization header. Allow ?token= and map it to Bearer.
  getRequest(context: any) {
    const req = context.switchToHttp().getRequest();
    const q: any = req.query || {};
    if (!req.headers?.authorization && q.token) {
      req.headers = req.headers || {};
      req.headers.authorization = `Bearer ${q.token}`;
    }
    return req;
  }
}
