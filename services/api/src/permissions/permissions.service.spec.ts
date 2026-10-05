import { PermissionsService } from './permissions.service';

/**
 * Admin-managed permissions. These pin the two things that MUST stay correct or
 * the whole feature becomes an authz hole:
 *
 *  1. Defaults preserve pre-feature behavior — teachers keep their tools,
 *     secretaries stay locked out of SECRETARY-grant capabilities.
 *  2. Overrides are honored, stored sparsely (deviations only), and ADMIN /
 *     MANAGER always pass regardless of what's stored.
 */
describe('PermissionsService — defaults, overrides, and super-roles', () => {
  function fakePrisma(permissions: any) {
    const school = { permissions };
    const prisma: any = {
      school: {
        findUnique: jest.fn().mockResolvedValue(school),
        update: jest.fn().mockImplementation((args: any) => {
          school.permissions = args.data.permissions;
          return Promise.resolve(school);
        }),
      },
    };
    return prisma;
  }

  const secretary = { roles: ['SECRETARY'], schoolId: 'sch-1' };
  const teacher = { roles: ['TEACHER'], schoolId: 'sch-1' };
  const admin = { roles: ['ADMIN'], schoolId: 'sch-1' };
  const manager = { roles: ['MANAGER'], schoolId: 'sch-1' };

  it('ADMIN and MANAGER always pass, even with everything stored off', async () => {
    const svc = new PermissionsService(
      fakePrisma({ TEACHER: { 'grades.edit': false }, SECRETARY: {} }),
    );
    expect(await svc.can(admin, 'grades.edit')).toBe(true);
    expect(await svc.can(admin, 'cohorts.manageMembers')).toBe(true);
    expect(await svc.can(manager, 'students.delete')).toBe(true);
  });

  it('TEACHER capabilities are ON by default (pre-feature behavior preserved)', async () => {
    const svc = new PermissionsService(fakePrisma(null));
    expect(await svc.can(teacher, 'grades.edit')).toBe(true);
    expect(await svc.can(teacher, 'materials.manage')).toBe(true);
    expect(await svc.can(teacher, 'exams.manage')).toBe(true);
    expect(await svc.can(teacher, 'certificates.manage')).toBe(true);
  });

  it('SECRETARY grant capabilities are OFF by default', async () => {
    const svc = new PermissionsService(fakePrisma(null));
    expect(await svc.can(secretary, 'cohorts.manageMembers')).toBe(false);
    expect(await svc.can(secretary, 'cohorts.manage')).toBe(false);
    expect(await svc.can(secretary, 'students.create')).toBe(false);
    expect(await svc.can(secretary, 'students.delete')).toBe(false);
    expect(await svc.can(secretary, 'certificates.manage')).toBe(false);
  });

  it('cmail.send is ON by default for both teacher and secretary', async () => {
    const svc = new PermissionsService(fakePrisma(null));
    expect(await svc.can(teacher, 'cmail.send')).toBe(true);
    expect(await svc.can(secretary, 'cmail.send')).toBe(true);
  });

  it('an admin override enables a SECRETARY-grant capability', async () => {
    const svc = new PermissionsService(
      fakePrisma({ SECRETARY: { 'cohorts.manageMembers': true } }),
    );
    expect(await svc.can(secretary, 'cohorts.manageMembers')).toBe(true);
    // unrelated cap still off
    expect(await svc.can(secretary, 'students.delete')).toBe(false);
  });

  it('an admin override disables a default-on TEACHER capability', async () => {
    const svc = new PermissionsService(
      fakePrisma({ TEACHER: { 'grades.edit': false } }),
    );
    expect(await svc.can(teacher, 'grades.edit')).toBe(false);
    // other teacher caps unaffected
    expect(await svc.can(teacher, 'materials.manage')).toBe(true);
  });

  it('unknown capability keys fail closed', async () => {
    const svc = new PermissionsService(fakePrisma(null));
    expect(await svc.can(secretary, 'not.a.real.key')).toBe(false);
    // ...but admins are allowed before the key is even considered
    expect(await svc.can(admin, 'not.a.real.key')).toBe(true);
  });

  it('setOverrides stores only deviations from default (sparse)', async () => {
    const prisma = fakePrisma(null);
    const svc = new PermissionsService(prisma);
    await svc.setOverrides('sch-1', {
      // deviation (secretary default off → on): kept
      SECRETARY: { 'cohorts.manageMembers': true, 'students.create': false },
      // matches default (teacher default on → on): dropped
      TEACHER: { 'grades.edit': true, 'exams.manage': false },
    });
    const stored = prisma.school.update.mock.calls[0][0].data.permissions;
    expect(stored).toEqual({
      SECRETARY: { 'cohorts.manageMembers': true },
      TEACHER: { 'exams.manage': false },
    });
  });

  it('grantedKeysFor lists exactly the keys a secretary holds', async () => {
    const svc = new PermissionsService(
      fakePrisma({ SECRETARY: { 'cohorts.manageMembers': true } }),
    );
    const keys = await svc.grantedKeysFor(secretary);
    expect(keys).toContain('cohorts.manageMembers');
    expect(keys).toContain('cmail.send'); // default on
    expect(keys).not.toContain('students.delete');
    expect(keys).not.toContain('grades.edit'); // teacher-only cap
  });

  it('getSchoolConfig reports effective + default per role', async () => {
    const svc = new PermissionsService(
      fakePrisma({ SECRETARY: { 'cohorts.manage': true } }),
    );
    const { capabilities } = await svc.getSchoolConfig('sch-1');
    const cohortManage = capabilities.find((c) => c.key === 'cohorts.manage')!;
    expect(cohortManage.roles['SECRETARY']).toEqual({ enabled: true, default: false });
    const gradesEdit = capabilities.find((c) => c.key === 'grades.edit')!;
    expect(gradesEdit.roles['TEACHER']).toEqual({ enabled: true, default: true });
  });

  // ── Schedule & announcements (added 2026-10-05) ───────────────────────────
  it('schedule.edit: OFF for secretary by default, never for teacher', async () => {
    const svc = new PermissionsService(fakePrisma(null));
    // Every schedule write was ADMIN-only before — the default must keep it so.
    expect(await svc.can(secretary, 'schedule.edit')).toBe(false);
    // Not configurable for teachers at all (no override can grant it).
    const svc2 = new PermissionsService(
      fakePrisma({ TEACHER: { 'schedule.edit': true } }),
    );
    expect(await svc2.can(teacher, 'schedule.edit')).toBe(false);
    expect(await svc.can(admin, 'schedule.edit')).toBe(true);
  });

  it('schedule.edit can be granted to a secretary by an admin', async () => {
    const svc = new PermissionsService(
      fakePrisma({ SECRETARY: { 'schedule.edit': true } }),
    );
    expect(await svc.can(secretary, 'schedule.edit')).toBe(true);
    expect(await svc.grantedKeysFor(secretary)).toContain('schedule.edit');
  });

  it('announcements.post: ON by default for teacher AND secretary (no regression)', async () => {
    const svc = new PermissionsService(fakePrisma(null));
    expect(await svc.can(teacher, 'announcements.post')).toBe(true);
    expect(await svc.can(secretary, 'announcements.post')).toBe(true);
  });

  it('announcements.post can be switched off per role', async () => {
    const svc = new PermissionsService(
      fakePrisma({ TEACHER: { 'announcements.post': false } }),
    );
    expect(await svc.can(teacher, 'announcements.post')).toBe(false);
    expect(await svc.can(secretary, 'announcements.post')).toBe(true);
    expect(await svc.can(admin, 'announcements.post')).toBe(true);
  });
});
