import { Reflector } from '@nestjs/core';
import { ExecutionContext } from '@nestjs/common';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { ROLES_KEY } from '../../auth/decorators/roles.decorator';
import { ALL_APP_ROLES, CLASSNOTES_ROLE, Role } from '../../auth/roles';

/// A ClassNotes account's session is confined to `/classnotes/*` by ONE thing:
/// it carries `CLASSNOTES` and no school role, and `CLASSNOTES` is deliberately
/// absent from `ALL_APP_ROLES`, so the RolesGuard's default-deny refuses it
/// everywhere it is not named explicitly.
///
/// That is a security boundary resting on an omission, which is exactly the kind
/// of thing a later "tidy-up" adds back without noticing. These tests fail if
/// anyone does.
describe('ClassNotes token isolation', () => {
  const guard = new RolesGuard(new Reflector());

  // `src/test/jest.env.ts` sets DEV_AUTH_BYPASS=1 so that older specs stay
  // green, and the FIRST thing RolesGuard does is return true when that is on.
  // Leaving it set does not just break the "denies" cases here — it makes every
  // assertion in this file vacuous, the "allows" ones included. These tests are
  // about what production does, so the bypass is off for all of them.
  const savedBypass = process.env.DEV_AUTH_BYPASS;
  beforeAll(() => {
    delete process.env.DEV_AUTH_BYPASS;
  });
  afterAll(() => {
    if (savedBypass === undefined) delete process.env.DEV_AUTH_BYPASS;
    else process.env.DEV_AUTH_BYPASS = savedBypass;
  });

  it('is testing the real guard, not the dev bypass', () => {
    // Guards against this whole file silently going green again.
    expect(process.env.DEV_AUTH_BYPASS).toBeUndefined();
  });

  /// A request context carrying `user`, for a handler tagged with `required`.
  function contextFor(required: readonly string[], user: unknown): ExecutionContext {
    const handler = () => undefined;
    Reflect.defineMetadata(ROLES_KEY, required, handler);
    return {
      getHandler: () => handler,
      getClass: () => class {},
      switchToHttp: () => ({ getRequest: () => ({ user }) }),
    } as unknown as ExecutionContext;
  }

  const classNotesSession = { roles: [CLASSNOTES_ROLE] };
  const studentSession = { roles: [Role.STUDENT] };

  it('keeps CLASSNOTES out of the catch-all role list', () => {
    // If this ever becomes true, every route tagged @Roles(...ALL_APP_ROLES) —
    // most of the school API — silently opens to notebook-app accounts.
    expect(ALL_APP_ROLES as readonly string[]).not.toContain(CLASSNOTES_ROLE);
  });

  it('denies a ClassNotes session on a route tagged with the catch-all only', () => {
    expect(guard.canActivate(contextFor(ALL_APP_ROLES, classNotesSession))).toBe(false);
  });

  it('allows a ClassNotes session on a route that names CLASSNOTES', () => {
    const required = [...ALL_APP_ROLES, CLASSNOTES_ROLE];
    expect(guard.canActivate(contextFor(required, classNotesSession))).toBe(true);
  });

  it('still allows a ClassMate user on that same route', () => {
    // The ClassMate app's own ClassNotes tab reads this library too, so adding
    // CLASSNOTES must not have cost the school roles their access.
    const required = [...ALL_APP_ROLES, CLASSNOTES_ROLE];
    expect(guard.canActivate(contextFor(required, studentSession))).toBe(true);
  });

  it('denies a ClassNotes session on a role-specific school route', () => {
    for (const required of [[Role.ADMIN], [Role.TEACHER], [Role.STUDENT], [Role.MANAGER]]) {
      expect(guard.canActivate(contextFor(required, classNotesSession))).toBe(false);
    }
  });

  it('denies a ClassNotes session on an untagged authenticated route', () => {
    expect(guard.canActivate(contextFor([], classNotesSession))).toBe(false);
  });
});
