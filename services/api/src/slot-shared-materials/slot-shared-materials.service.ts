import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

/// Shared, class-wide materials attached to a schedule period by any
/// participant (students AND teachers). Distinct from the teacher's curated
/// TeacherMaterial library — this is a collaborative drop box per period.
@Injectable()
export class SlotSharedMaterialsService {
  constructor(private readonly prisma: PrismaService) {}

  private uid(user: any): string {
    return String(user?.sub ?? user?.id ?? user?.userId ?? '').trim();
  }
  private isStaff(user: any): boolean {
    const roles: string[] = Array.isArray(user?.roles) ? user.roles : [];
    return roles.includes('TEACHER') || roles.includes('ADMIN') || roles.includes('SECRETARY');
  }

  private async getSlotOrThrow(slotId: string) {
    const slot = await this.prisma.scheduleSlot.findUnique({
      where: { id: slotId },
      select: { id: true, schoolId: true, teacherId: true, subject: true, period: true, dayOfWeek: true,
        teacher: { select: { name: true } } },
    });
    if (!slot) throw new NotFoundException('Period not found');
    return slot;
  }

  /// Same-school check — students only ever reach slot ids from their own
  /// schedule, and staff act within their school.
  private assertSameSchool(user: any, slot: { schoolId: string | null }) {
    const schoolId = (user as any)?.schoolId ?? null;
    if (schoolId && slot.schoolId && slot.schoolId !== schoolId) {
      throw new ForbiddenException('That period is not in your school');
    }
  }

  private shape(m: any, user: any, slotTeacherId: string | null) {
    const me = this.uid(user);
    const roles: string[] = Array.isArray(user?.roles) ? user.roles : [];
    // You can delete your own post; the period's teacher and admins can remove any.
    const canDelete = m.uploaderId === me || (!!slotTeacherId && slotTeacherId === me) || roles.includes('ADMIN');
    return {
      id: m.id,
      caption: m.caption ?? '',
      fileUrl: m.fileUrl,
      fileName: m.fileName ?? '',
      mimeType: m.mimeType ?? '',
      date: m.date ?? '',
      uploaderId: m.uploaderId,
      uploaderName: m.uploader?.name ?? '',
      canDelete,
      createdAt: m.createdAt,
    };
  }

  async listForSlot(user: any, slotId: string) {
    const slot = await this.getSlotOrThrow(slotId);
    this.assertSameSchool(user, slot);
    const rows = await this.prisma.slotSharedMaterial.findMany({
      where: { slotId },
      orderBy: { createdAt: 'desc' },
      include: { uploader: { select: { name: true } } },
    });
    return { ok: true, materials: rows.map((m) => this.shape(m, user, slot.teacherId)) };
  }

  async addToSlot(user: any, slotId: string, body: any) {
    const slot = await this.getSlotOrThrow(slotId);
    this.assertSameSchool(user, slot);
    const fileUrl = String(body?.fileUrl ?? '').trim();
    if (!fileUrl) throw new BadRequestException('fileUrl is required');
    const created = await this.prisma.slotSharedMaterial.create({
      data: {
        slotId,
        uploaderId: this.uid(user),
        date: String(body?.date ?? '').trim(),
        caption: String(body?.caption ?? '').trim(),
        fileUrl,
        fileName: String(body?.fileName ?? '').trim(),
        mimeType: String(body?.mimeType ?? '').trim(),
      },
      include: { uploader: { select: { name: true } } },
    });
    return { ok: true, material: this.shape(created, user, slot.teacherId) };
  }

  async remove(user: any, id: string) {
    const m = await this.prisma.slotSharedMaterial.findUnique({
      where: { id },
      select: { id: true, uploaderId: true, slot: { select: { teacherId: true } } },
    });
    if (!m) throw new NotFoundException('Material not found');
    const me = this.uid(user);
    const roles: string[] = Array.isArray(user?.roles) ? user.roles : [];
    const allowed = m.uploaderId === me || m.slot?.teacherId === me || roles.includes('ADMIN');
    if (!allowed) throw new ForbiddenException('You can only remove your own material');
    await this.prisma.slotSharedMaterial.delete({ where: { id } });
    return { ok: true };
  }

  /// All shared materials for periods the current user takes part in — drives
  /// the "Class Materials" drawer tab. Teachers/admins see periods they teach;
  /// students see periods in their cohorts / grade / direct assignment.
  async mine(user: any) {
    const me = this.uid(user);
    const schoolId = (user as any)?.schoolId ?? null;
    let slotIds: string[];

    if (this.isStaff(user)) {
      const slots = await this.prisma.scheduleSlot.findMany({
        where: { teacherId: me }, select: { id: true },
      });
      slotIds = slots.map((s) => s.id);
    } else {
      const [links, profile] = await Promise.all([
        this.prisma.studentCohort.findMany({ where: { studentId: me }, select: { cohortId: true } }),
        this.prisma.studentProfile.findUnique({ where: { userId: me }, select: { grade: true, cohortId: true } }),
      ]);
      const cohortIds = [
        ...links.map((l) => l.cohortId),
        ...(profile?.cohortId ? [profile.cohortId] : []),
      ];
      const grade = profile?.grade ?? null;
      const slots = await this.prisma.scheduleSlot.findMany({
        where: {
          ...(schoolId ? { schoolId } : {}),
          OR: [
            ...(cohortIds.length ? [{ cohorts: { some: { cohortId: { in: cohortIds } } } }] : []),
            { students: { some: { studentId: me } } },
            ...(grade != null ? [{ audienceGrade: grade }] : []),
          ],
        },
        select: { id: true },
      });
      slotIds = slots.map((s) => s.id);
    }

    if (!slotIds.length) return { ok: true, materials: [] };

    const rows = await this.prisma.slotSharedMaterial.findMany({
      where: { slotId: { in: slotIds } },
      orderBy: { createdAt: 'desc' },
      include: {
        uploader: { select: { name: true } },
        slot: { select: { teacherId: true, subject: true, period: true, dayOfWeek: true, teacher: { select: { name: true } } } },
      },
    });

    return {
      ok: true,
      materials: rows.map((m) => ({
        ...this.shape(m, user, m.slot?.teacherId ?? null),
        slotId: m.slotId,
        subject: m.slot?.subject ?? '',
        period: m.slot?.period ?? null,
        dayOfWeek: m.slot?.dayOfWeek ?? null,
        teacherName: m.slot?.teacher?.name ?? '',
      })),
    };
  }
}
