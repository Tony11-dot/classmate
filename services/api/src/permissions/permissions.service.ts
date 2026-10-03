import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { getRoles } from '../auth/permissions';
import {
  PERMISSION_CATALOG,
  CAPABILITY_BY_KEY,
  CAPABILITY_KEYS,
  CONFIGURABLE_ROLES,
  ConfigurableRole,
  PermissionOverrides,
} from './permissions.catalog';
import { Role } from '../auth/roles';

/**
 * Resolves effective capabilities for a user by merging the catalog defaults
 * with a school's sparse `School.permissions` overrides.
 *
 * Per-school overrides are cached in-memory with a short TTL so the global
 * PermissionsGuard can run on every request without a DB round-trip each time.
 * The cache is invalidated immediately on save (setOverrides).
 */
@Injectable()
export class PermissionsService {
  private readonly cache = new Map<
    string,
    { overrides: PermissionOverrides; at: number }
  >();
  private static readonly TTL_MS = 60_000;

  constructor(private readonly prisma: PrismaService) {}

  /** Admins and the platform manager always hold every capability. */
  private static isSuper(user: any): boolean {
    const roles = getRoles(user);
    return roles.includes('ADMIN') || roles.includes('MANAGER');
  }

  private async loadOverrides(schoolId: string | null | undefined): Promise<PermissionOverrides> {
    if (!schoolId) return {};
    const hit = this.cache.get(schoolId);
    if (hit && Date.now() - hit.at < PermissionsService.TTL_MS) return hit.overrides;

    const school = await this.prisma.school.findUnique({
      where: { id: schoolId },
      select: { permissions: true },
    });
    const overrides = this.normalizeOverrides((school as any)?.permissions);
    this.cache.set(schoolId, { overrides, at: Date.now() });
    return overrides;
  }

  /** Keep only known roles + known keys with boolean values. */
  private normalizeOverrides(raw: any): PermissionOverrides {
    const out: PermissionOverrides = {};
    if (!raw || typeof raw !== 'object') return out;
    for (const role of CONFIGURABLE_ROLES) {
      const roleMap = raw[role];
      if (!roleMap || typeof roleMap !== 'object') continue;
      const kept: Record<string, boolean> = {};
      for (const [key, val] of Object.entries(roleMap)) {
        if (CAPABILITY_KEYS.has(key) && typeof val === 'boolean') kept[key] = val;
      }
      if (Object.keys(kept).length) out[role] = kept;
    }
    return out;
  }

  /** Default-on check for a single (role, key): catalog default unless overridden. */
  private effective(
    overrides: PermissionOverrides,
    role: ConfigurableRole,
    key: string,
  ): boolean {
    const override = overrides[role]?.[key];
    if (typeof override === 'boolean') return override;
    const cap = CAPABILITY_BY_KEY[key];
    return !!cap && cap.defaultRoles.includes(role);
  }

  /**
   * Can this user perform the capability `key`? ADMIN/MANAGER always yes;
   * otherwise the user needs at least one of their configurable roles to hold
   * it (by default or override).
   */
  async can(user: any, key: string): Promise<boolean> {
    if (PermissionsService.isSuper(user)) return true;
    const cap = CAPABILITY_BY_KEY[key];
    if (!cap) return false; // unknown key → deny (fail closed)

    const overrides = await this.loadOverrides((user as any)?.schoolId);
    const roles = getRoles(user);
    for (const role of cap.configurableRoles) {
      if (roles.includes(role) && this.effective(overrides, role, key)) return true;
    }
    return false;
  }

  /**
   * The full set of capability keys this user effectively holds — attached to
   * `req.user.grantedPermissions` by the guard so sync service code can check
   * grants without another async hop.
   */
  async grantedKeysFor(user: any): Promise<string[]> {
    if (PermissionsService.isSuper(user)) return PERMISSION_CATALOG.map((c) => c.key);
    const overrides = await this.loadOverrides((user as any)?.schoolId);
    const roles = getRoles(user);
    const granted: string[] = [];
    for (const cap of PERMISSION_CATALOG) {
      for (const role of cap.configurableRoles) {
        if (roles.includes(role) && this.effective(overrides, role, cap.key)) {
          granted.push(cap.key);
          break;
        }
      }
    }
    return granted;
  }

  /**
   * Build the admin-facing config view for a school: every capability with its
   * current effective value per configurable role, so the UI can render the
   * checklist and show which switches deviate from default.
   */
  async getSchoolConfig(schoolId: string | null | undefined) {
    const overrides = await this.loadOverrides(schoolId);
    const capabilities = PERMISSION_CATALOG.map((cap) => ({
      key: cap.key,
      module: cap.module,
      label: cap.label,
      description: cap.description,
      configurableRoles: cap.configurableRoles,
      defaultRoles: cap.defaultRoles,
      roles: cap.configurableRoles.reduce((acc, role) => {
        acc[role] = {
          enabled: this.effective(overrides, role, cap.key),
          default: cap.defaultRoles.includes(role),
        };
        return acc;
      }, {} as Record<string, { enabled: boolean; default: boolean }>),
    }));
    return { capabilities };
  }

  /**
   * Persist a full set of toggles for a school. `changes` is { ROLE: { key: bool } }.
   * We store only deviations from default (sparse) and drop anything that
   * matches the catalog default again, so the JSON stays small and readable.
   */
  async setOverrides(schoolId: string, incoming: any): Promise<PermissionOverrides> {
    const normalized = this.normalizeOverrides(incoming);
    // Collapse to deviations-only.
    const sparse: PermissionOverrides = {};
    for (const role of CONFIGURABLE_ROLES) {
      const roleMap = normalized[role];
      if (!roleMap) continue;
      const kept: Record<string, boolean> = {};
      for (const [key, val] of Object.entries(roleMap)) {
        const cap = CAPABILITY_BY_KEY[key];
        if (!cap || !cap.configurableRoles.includes(role)) continue; // not toggleable for this role
        const def = cap.defaultRoles.includes(role);
        if (val !== def) kept[key] = val; // only persist real deviations
      }
      if (Object.keys(kept).length) sparse[role] = kept;
    }

    await this.prisma.school.update({
      where: { id: schoolId },
      data: { permissions: sparse as any },
    });
    this.cache.set(schoolId, { overrides: sparse, at: Date.now() });
    return sparse;
  }

  /** Drop a school's cached overrides (e.g. after an external write). */
  invalidate(schoolId: string) {
    this.cache.delete(schoolId);
  }
}
