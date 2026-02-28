import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { ActorContext } from './actor-context';
import type { RequestUser } from './request-user';

export const CurrentActor = createParamDecorator((_data: unknown, ctx: ExecutionContext) => {
  const req = ctx.switchToHttp().getRequest<{ user?: RequestUser; actor?: ActorContext }>();
  return req.actor ?? null;
});
