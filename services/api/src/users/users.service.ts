import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface UserProfileDto {
  id: string;
  displayName: string;
  initials: string;
  role: string;
  schoolName: string | null;
  /// Grade label like "Grade 11" — only populated for students.
  grade: string | null;
  /// Cohort short-name (after the leading "11-") — students only.
  cohortName: string | null;
  /// For parents: the list of their children (id, name, grade) — empty
  /// for everyone else.
  children: Array<{ id: string; name: string; grade: string | null }>;
  /// For students: the list of their approved parents — empty for
  /// everyone else.
  parents: Array<{ id: string; name: string }>;
}

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  /// Lightweight profile of a user for chat-thread / member-list views.
  /// Same-school enforced — a viewer in school A can't read profiles
  /// in school B (prevents cross-school enumeration).
  async getProfile(viewerId: string, targetId: string): Promise<UserProfileDto> {
    const target = await this.prisma.user.findUnique({
      where: { id: targetId },
      select: {
        id: true,
        name: true,
        schoolId: true,
        school: { select: { name: true } },
        roles: { select: { role: true } },
        studentProfile: {
          select: {
            cohort: { select: { name: true, grade: true } },
          },
        },
      },
    });
    if (!target) throw new NotFoundException('User not found');

    const viewer = await this.prisma.user.findUnique({
      where: { id: viewerId },
      select: { schoolId: true, roles: { select: { role: true } } },
    });
    // Fail-closed: if the target belongs to a school, the viewer must be in
    // that same school. (Previously this only fired when BOTH sides had a
    // schoolId, so a null-school viewer could read any school's profiles.)
    if (target.schoolId && viewer?.schoolId !== target.schoolId) {
      throw new ForbiddenException('Cannot view profile from another school');
    }

    const roles = target.roles.map((r) => String(r.role).toUpperCase());
    const primaryRole =
      roles.find((r) => r === 'TEACHER') ??
      roles.find((r) => r === 'ADMIN') ??
      roles.find((r) => r === 'SECRETARY') ??
      roles.find((r) => r === 'PARENT') ??
      roles[0] ??
      'STUDENT';

    const displayName = String(target.name ?? '').trim() || 'Member';
    const initials = this.initialsOf(displayName);

    const grade = target.studentProfile?.cohort?.grade
      ? `Grade ${target.studentProfile.cohort.grade}`
      : null;
    const cohortName = target.studentProfile?.cohort?.name?.replace(/^\d+\s*-\s*/, '') ?? null;

    let children: UserProfileDto['children'] = [];
    if (roles.includes('PARENT')) {
      const links = await this.prisma.parentChild.findMany({
        where: { parentId: targetId, status: 'APPROVED' as any },
        include: {
          child: {
            select: {
              id: true,
              name: true,
              studentProfile: {
                select: { cohort: { select: { grade: true } } },
              },
            },
          },
        },
      });
      children = links.map((l) => ({
        id: l.child.id,
        name: String(l.child.name ?? '').trim(),
        grade: l.child.studentProfile?.cohort?.grade
          ? `Grade ${l.child.studentProfile.cohort.grade}`
          : null,
      }));
    }

    let parents: UserProfileDto['parents'] = [];
    if (roles.includes('STUDENT')) {
      const links = await this.prisma.parentChild.findMany({
        where: { childId: targetId, status: 'APPROVED' as any },
        include: {
          parent: {
            select: { id: true, name: true },
          },
        },
      });
      parents = links.map((l) => ({
        id: l.parent.id,
        name: String(l.parent.name ?? '').trim(),
      }));
    }

    return {
      id: target.id,
      displayName,
      initials,
      role: primaryRole,
      schoolName: target.school?.name ?? null,
      grade,
      cohortName,
      children,
      parents,
    };
  }

  private initialsOf(name: string): string {
    const parts = String(name ?? '').trim().split(/\s+/).filter(Boolean);
    if (!parts.length) return '?';
    if (parts.length === 1) return parts[0]!.slice(0, 2).toUpperCase();
    return (parts[0]![0]! + parts[parts.length - 1]![0]!).toUpperCase();
  }
}
