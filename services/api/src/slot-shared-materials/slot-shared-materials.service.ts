import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/// Lets students (and teachers) add a material to a schedule period from the
/// period detail sheet. The material is a NORMAL `TeacherMaterial` attached to
/// the slot via `ScheduleSlotMaterial` — so it shows up in the exact same
/// places teacher materials do: the period sheet's attachment list AND the
/// student/teacher Materials tab. The student only supplies a title + files;
/// the subject and audience are INHERITED from the period.
@Injectable()
export class SlotSharedMaterialsService {
  constructor(private readonly prisma: PrismaService) {}

  private uid(user: any): string {
    return String(user?.sub ?? user?.id ?? user?.userId ?? '').trim();
  }
  private roles(user: any): string[] {
    return Array.isArray(user?.roles) ? user.roles : [];
  }
  private isAdmin(user: any): boolean {
    return this.roles(user).includes('ADMIN') || this.roles(user).includes('SECRETARY');
  }

  private normalizeDate(raw: any): string {
    const s = typeof raw === 'string' ? raw.trim() : '';
    return /^\d{4}-\d{2}-\d{2}$/.test(s) ? s : '';
  }

  private async getSlotOrThrow(slotId: string) {
    const slot = await this.prisma.scheduleSlot.findUnique({
      where: { id: slotId },
      select: {
        id: true, schoolId: true, teacherId: true, subject: true,
        audienceGrade: true,
        students: { select: { studentId: true } },
        cohorts: { select: { cohortId: true } },
      },
    });
    if (!slot) throw new NotFoundException('Period not found');
    return slot;
  }

  /// Students may only touch periods in their own audience; the period teacher
  /// and admins may always. Same-school is enforced for everyone.
  private async assertCanAccess(user: any, slot: Awaited<ReturnType<SlotSharedMaterialsService['getSlotOrThrow']>>) {
    const me = this.uid(user);
    const schoolId = (user as any)?.schoolId ?? null;
    if (schoolId && slot.schoolId && slot.schoolId !== schoolId) {
      throw new ForbiddenException('That period is not in your school');
    }
    if (this.isAdmin(user) || (slot.teacherId && slot.teacherId === me)) return;

    // Student path — must be in the slot's audience.
    if (slot.students.some((s) => s.studentId === me)) return;
    const [links, profile] = await Promise.all([
      this.prisma.studentCohort.findMany({ where: { studentId: me }, select: { cohortId: true } }),
      this.prisma.studentProfile.findUnique({ where: { userId: me }, select: { grade: true, cohortId: true } }),
    ]);
    const myCohorts = new Set<string>([
      ...links.map((l) => l.cohortId),
      ...(profile?.cohortId ? [profile.cohortId] : []),
    ]);
    if (slot.cohorts.some((c) => myCohorts.has(c.cohortId))) return;
    if (slot.audienceGrade != null && profile?.grade === slot.audienceGrade) return;

    throw new ForbiddenException('That period is not in your schedule');
  }

  /// Shape a TeacherMaterial row into the attachment payload the period sheet
  /// + materials list already understand, plus delete permission.
  private shape(m: any, user: any, slotTeacherId: string | null) {
    const me = this.uid(user);
    const list = Array.isArray(m?.attachments) ? m.attachments : [];
    const first = list.find((a: any) => a && typeof a === 'object') ?? null;
    const url = (typeof m?.url === 'string' && m.url.length > 0)
      ? m.url
      : (first && typeof first.url === 'string' ? first.url : '');
    const mime = first && typeof first.mime === 'string' ? first.mime : '';
    const canDelete = (m.uploaderId && m.uploaderId === me)
      || m.teacherId === me
      || (!!slotTeacherId && slotTeacherId === me)
      || this.isAdmin(user);
    return {
      id: m.id,
      title: m.title ?? 'Material',
      url,
      mime,
      subject: m.subject ?? null,
      attachments: list,
      uploaderName: m.uploader?.name ?? m.teacher?.name ?? '',
      canDelete,
    };
  }

  async listForSlot(user: any, slotId: string, date?: string) {
    const slot = await this.getSlotOrThrow(slotId);
    await this.assertCanAccess(user, slot);
    const d = this.normalizeDate(date);
    const where: any = { slotId };
    if (d) where.date = { in: [d, ''] };
    const rows = await this.prisma.scheduleSlotMaterial.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      include: {
        material: {
          include: {
            teacher: { select: { name: true } },
          },
        },
      },
    });
    return {
      ok: true,
      materials: rows
        .filter((r) => r.material)
        .map((r) => ({ ...this.shape(r.material, user, slot.teacherId), date: (r as any).date ?? '' })),
    };
  }

  /// Create a slot-scoped material. Body: { title, attachments:[{url,name,mime}], date? }.
  async addToSlot(user: any, slotId: string, body: any) {
    const slot = await this.getSlotOrThrow(slotId);
    await this.assertCanAccess(user, slot);

    const me = this.uid(user);
    const title = String(body?.title ?? '').trim();
    const attachments = Array.isArray(body?.attachments) ? body.attachments : [];
    if (!title) throw new BadRequestException('title is required');
    if (!attachments.length) throw new BadRequestException('at least one file is required');
    const primaryUrl = (attachments[0] && typeof attachments[0].url === 'string') ? attachments[0].url : null;
    const d = this.normalizeDate(body?.date);

    // Owned by the period's teacher so it groups under the right teacher in
    // the materials tab; falls back to the uploader when the slot has none.
    const ownerId = slot.teacherId || me;
    const cohortIds = slot.cohorts.map((c) => c.cohortId);
    const studentIds = slot.students.map((s) => s.studentId);

    const material = await this.prisma.teacherMaterial.create({
      data: {
        teacherId: ownerId,
        uploaderId: me,
        title,
        url: primaryUrl,
        attachments: attachments as any,
        subject: slot.subject ?? null,
        // Scope to the period's audience — NOT EVERYONE (which would broadcast
        // school-wide). Visibility resolves via targetStudentIds (expanded
        // below) + the slot-cascade path in the student materials feed.
        targetType: 'STUDENTS',
        targetCohortIds: cohortIds,
        targetStudentIds: studentIds,
        targetGrades: slot.audienceGrade != null ? [slot.audienceGrade] : [],
        published: true,
      },
      include: { teacher: { select: { name: true } } },
    });

    await this.prisma.scheduleSlotMaterial.create({
      data: { slotId, teacherMaterialId: material.id, date: d },
    });
    await this.expandAudienceFromSlot(material.id, slot);

    return { ok: true, material: this.shape(material, user, slot.teacherId) };
  }

  async remove(user: any, id: string) {
    const m = await this.prisma.teacherMaterial.findUnique({
      where: { id },
      select: { id: true, uploaderId: true, teacherId: true },
    });
    if (!m) throw new NotFoundException('Material not found');
    const me = this.uid(user);
    let allowed = (m.uploaderId && m.uploaderId === me) || m.teacherId === me;
    // An admin may remove others' material, but only within their OWN school —
    // otherwise an admin of any school could delete another school's material
    // by guessing/knowing its id.
    if (!allowed && this.isAdmin(user)) {
      const callerSchool = (user as any)?.schoolId ?? null;
      const owner = m.teacherId
        ? await this.prisma.user.findUnique({ where: { id: m.teacherId }, select: { schoolId: true } })
        : null;
      allowed = !!callerSchool && !!owner?.schoolId && owner.schoolId === callerSchool;
    }
    if (!allowed) throw new ForbiddenException('You can only remove material you added');
    // Cascade removes the ScheduleSlotMaterial junction rows.
    await this.prisma.teacherMaterial.delete({ where: { id } });
    return { ok: true };
  }

  /// Pull every student the slot targets into the material's targetStudentIds
  /// so classmates see it in their Materials feed (mirrors the teacher flow).
  private async expandAudienceFromSlot(
    materialId: string,
    slot: Awaited<ReturnType<SlotSharedMaterialsService['getSlotOrThrow']>>,
  ) {
    const ids = new Set<string>();
    for (const s of slot.students) ids.add(s.studentId);
    if (slot.cohorts.length) {
      const members = await this.prisma.studentCohort.findMany({
        where: { cohortId: { in: slot.cohorts.map((c) => c.cohortId) } },
        select: { studentId: true },
      });
      for (const m of members) ids.add(m.studentId);
    }
    if (slot.audienceGrade != null) {
      const gradeStudents = await this.prisma.studentProfile.findMany({
        where: {
          grade: slot.audienceGrade,
          ...(slot.schoolId ? { user: { schoolId: slot.schoolId } } : {}),
        },
        select: { userId: true },
      });
      for (const s of gradeStudents) ids.add(s.userId);
    }
    if (ids.size === 0) return;
    const cur = await this.prisma.teacherMaterial.findUnique({
      where: { id: materialId },
      select: { targetStudentIds: true },
    });
    if (!cur) return;
    const existing = new Set(cur.targetStudentIds);
    const merged = [...cur.targetStudentIds];
    for (const id of ids) if (!existing.has(id)) merged.push(id);
    if (merged.length === cur.targetStudentIds.length) return;
    await this.prisma.teacherMaterial.update({
      where: { id: materialId },
      data: { targetStudentIds: merged },
    });
  }
}
