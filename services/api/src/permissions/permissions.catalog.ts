import { Role } from '../auth/roles';

/**
 * ──────────────────────────────────────────────────────────────────────────
 *  Admin-managed permissions — capability catalog
 * ──────────────────────────────────────────────────────────────────────────
 *
 * A single, declarative source of truth for every capability an admin can turn
 * on or off per role, from the in-app "Permissions" screen. The backend guard
 * (permissions.guard.ts) and the Flutter checklist UI both read this catalog so
 * they never drift.
 *
 * Two kinds of capability, by design:
 *
 *  • SECRETARY-grant  — `defaultRoles` does NOT include SECRETARY. The capability
 *    is OFF for secretaries until an admin switches it on. These are wired on
 *    school-scoped admin endpoints that are safe to extend to a trusted office
 *    secretary (cohort membership, student records, certificates, school mail).
 *
 *  • TEACHER-toggle   — `defaultRoles` DOES include TEACHER. The capability is ON
 *    for teachers by default (preserving today's behavior) and an admin can
 *    switch it OFF to lock a teacher out of that action.
 *
 * ADMIN and MANAGER are never listed in `configurableRoles` — they always pass,
 * so the screen never offers a toggle that could lock an admin out of their own
 * tools. The stored overrides on `School.permissions` are sparse: only a role +
 * key that deviates from `defaultRoles` is persisted.
 */

export type ConfigurableRole = Role.SECRETARY | Role.TEACHER;

export interface Capability {
  /** Stable key persisted in overrides and referenced by @RequirePermission. */
  key: string;
  /** Grouping shown as a section header in the UI. */
  module: string;
  /** Short human label for the checklist row. */
  label: string;
  /** One-line explanation of exactly what the capability unlocks. */
  description: string;
  /** Which roles an admin may toggle for this capability. */
  configurableRoles: ConfigurableRole[];
  /** Roles that hold this capability by default (the pre-feature behavior). */
  defaultRoles: ConfigurableRole[];
}

/**
 * The catalog. Keep keys stable once shipped — they are persisted in
 * `School.permissions` and compiled into `@RequirePermission(...)` on endpoints.
 */
export const PERMISSION_CATALOG: Capability[] = [
  // ── Classes & students (SECRETARY-grant: off until enabled) ───────────────
  {
    key: 'cohorts.manageMembers',
    module: 'Classes & Students',
    label: 'Add / remove students in classes',
    description:
      'Place students into classes and remove them from the class roster.',
    configurableRoles: [Role.SECRETARY],
    defaultRoles: [],
  },
  {
    key: 'cohorts.manage',
    module: 'Classes & Students',
    label: 'Create, edit & delete classes',
    description: 'Create new classes, rename them, set grades, and delete them.',
    configurableRoles: [Role.SECRETARY],
    defaultRoles: [],
  },
  {
    key: 'students.create',
    module: 'Classes & Students',
    label: 'Add student accounts',
    description:
      'Create new student accounts in the school. (Teacher/admin accounts stay admin-only.)',
    configurableRoles: [Role.SECRETARY],
    defaultRoles: [],
  },
  {
    key: 'students.delete',
    module: 'Classes & Students',
    label: 'Delete student accounts',
    description:
      'Permanently delete student accounts. (Only student accounts — never staff.)',
    configurableRoles: [Role.SECRETARY],
    defaultRoles: [],
  },

  // ── Communication (toggle: on by default for staff, admin can disable) ────
  {
    key: 'cmail.send',
    module: 'Communication',
    label: 'Send school mail (CMail)',
    description: 'Compose and send school-wide mail to students, parents and staff.',
    configurableRoles: [Role.SECRETARY, Role.TEACHER],
    defaultRoles: [Role.SECRETARY, Role.TEACHER],
  },

  // ── Certificates (shared: SECRETARY-grant + TEACHER-toggle) ───────────────
  {
    key: 'certificates.manage',
    module: 'Certificates',
    label: 'Create & edit certificates',
    description: 'Issue, edit and publish student certificates.',
    configurableRoles: [Role.SECRETARY, Role.TEACHER],
    // Teachers issue certificates today; secretaries do not until granted.
    defaultRoles: [Role.TEACHER],
  },

  // ── Teaching tools (TEACHER-toggle: on by default, admin can disable) ─────
  {
    key: 'grades.edit',
    module: 'Teaching',
    label: 'Enter & edit grades',
    description:
      'Record and change grades and assessment scores for their classes.',
    configurableRoles: [Role.TEACHER],
    defaultRoles: [Role.TEACHER],
  },
  {
    key: 'materials.manage',
    module: 'Teaching',
    label: 'Manage class materials',
    description: 'Upload, edit and delete learning materials in their classrooms.',
    configurableRoles: [Role.TEACHER],
    defaultRoles: [Role.TEACHER],
  },
  {
    key: 'assignments.manage',
    module: 'Teaching',
    label: 'Manage assignments',
    description: 'Create, edit and delete assignments for their classes.',
    configurableRoles: [Role.TEACHER],
    defaultRoles: [Role.TEACHER],
  },
  {
    key: 'exams.manage',
    module: 'Teaching',
    label: 'Manage exams',
    description: 'Create, schedule, edit and delete exams.',
    configurableRoles: [Role.TEACHER],
    defaultRoles: [Role.TEACHER],
  },
  {
    key: 'meetings.manage',
    module: 'Teaching',
    label: 'Manage online meetings',
    description: 'Schedule and manage live/online class meetings.',
    configurableRoles: [Role.TEACHER],
    defaultRoles: [Role.TEACHER],
  },
  {
    key: 'forms.manage',
    module: 'Teaching',
    label: 'Manage forms',
    description: 'Create, edit and delete forms and collect responses.',
    configurableRoles: [Role.TEACHER],
    defaultRoles: [Role.TEACHER],
  },
];

/** Fast lookup by key. */
export const CAPABILITY_BY_KEY: Record<string, Capability> =
  PERMISSION_CATALOG.reduce((acc, c) => {
    acc[c.key] = c;
    return acc;
  }, {} as Record<string, Capability>);

/** Every capability key, for validation of incoming override payloads. */
export const CAPABILITY_KEYS = new Set(PERMISSION_CATALOG.map((c) => c.key));

/** Roles that can be configured at all (used to validate payloads + build UI). */
export const CONFIGURABLE_ROLES: ConfigurableRole[] = [Role.SECRETARY, Role.TEACHER];

/** Stored override shape: { ROLE: { capKey: bool } }. */
export type PermissionOverrides = Partial<
  Record<ConfigurableRole, Record<string, boolean>>
>;
