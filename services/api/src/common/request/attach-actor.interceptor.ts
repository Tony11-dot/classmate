import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { normalizeRoles, Role } from '../../auth/roles';
import type { ActorContext } from './actor-context';
import type { RequestUser } from './request-user';
import { requestUserId } from './request-user';

@Injectable()
export class AttachActorInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest<{ user?: RequestUser; actor?: ActorContext }>();

    const u = (req.user ?? {}) as RequestUser;
    const userId = requestUserId(u) ?? '';

    // choose a single "primary" role for convenience (still keep array in req.user.roles)
    const roles = normalizeRoles(u.roles ?? []);
    const primary = (roles[0] ?? Role.STUDENT) as any;

    const actor: ActorContext = {
      type: 'USER',
      userId,
      role: primary,
      schoolId: u.schoolId ? String(u.schoolId) : undefined,
      actingStudentId: u.actingStudentId ? String(u.actingStudentId) : undefined,
    };

    req.actor = actor;
    return next.handle();
  }
}
