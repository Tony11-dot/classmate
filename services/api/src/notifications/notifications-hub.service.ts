import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeService } from '../realtime/realtime.service';
import { ParentNotificationsEvents } from '../parent/parent-notifications.events';
import { PushService } from './push.service';

export type NotificationKind =
  | 'ANNOUNCEMENT'
  | 'GRADE_POSTED'
  | 'ATTENDANCE_RECORDED'
  | 'ATTENDANCE_ALERT'
  | 'NEW_ASSIGNMENT'
  | 'NEW_MATERIAL'
  | 'NEW_MEETING'
  | 'NEW_EXAM'
  | 'NEW_FORM'
  | 'NEW_DIPLOMA'
  | 'NEW_MESSAGE'
  | 'CLASSROOM_INVITE'
  | 'CLASSROOM_UPDATE';

export interface NotifyParams {
  /// Direct student/teacher/admin/secretary recipients of this event.
  /// Each gets a Notification row + an SSE push on /realtime/stream.
  recipientUserIds: string[];

  /// Notification category — used by the client to render an icon /
  /// color / deep-link target.
  type: NotificationKind | string;

  /// Headline copy (max ~60 chars).
  title: string;

  /// Optional longer body. Markdown not rendered — plain text only.
  body?: string;

  /// Free-form JSON for the client to render context (e.g. classroomId,
  /// announcementId, assignmentId). Tap-target deep-link data lives here.
  data?: Record<string, unknown>;

  /// When true (default), every student in `recipientUserIds` also
  /// generates a ParentNotification for each of their approved parents,
  /// AND a push on /parent/notifications/stream. Set false for cases
  /// where parent already gets a dedicated notification (e.g. a DM
  /// directly to the parent shouldn't fan out — the parent IS the
  /// direct recipient).
  fanOutToParents?: boolean;

  /// 'info' (default) | 'warning' | 'critical'. The client uses this to
  /// tint the banner / icon.
  severity?: 'info' | 'warning' | 'critical';
}

/// One ring to rule them all. Every domain write that should notify a
/// human ends with `hub.notify({...})`. The hub owns:
///   1. Notification + ParentNotification row persistence (dedup'd
///      across recipients in a single transaction).
///   2. SSE push to every connected recipient (student stream).
///   3. SSE push to every connected parent (parent stream).
///   4. Parent fan-out — when a student is the direct recipient, the
///      hub also creates ParentNotification rows for the student's
///      approved parents so they see the same event in /parent/notifications.
///
/// Never throws — a failed notify must never break the underlying
/// domain write (the grade is saved even if the notification dispatch
/// fails). Errors are console.errored for ops visibility.
@Injectable()
export class NotificationsHubService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly realtime: RealtimeService,
    private readonly parentEvents: ParentNotificationsEvents,
    private readonly push: PushService,
  ) {}

  async notify(params: NotifyParams): Promise<void> {
    const recipients = (params.recipientUserIds ?? [])
      .map((id) => String(id ?? '').trim())
      .filter((id) => id.length > 0);
    if (recipients.length === 0) return;

    const uniqueRecipients = Array.from(new Set(recipients));
    const fanOut = params.fanOutToParents !== false;

    try {
      // Persist the recipient rows.
      const data = uniqueRecipients.map((userId) => ({
        userId,
        type: String(params.type),
        title: params.title,
        body: params.body ?? null,
        data: (params.data ?? {}) as any,
        severity: params.severity ?? 'info',
      }));
      await this.prisma.notification.createMany({ data });
    } catch (e) {
      console.error('[notifications-hub] failed to persist Notification rows:', e);
    }

    // SSE-push every recipient. emitToUser is a no-op for users not
    // currently connected, so this is cheap regardless of fanout size.
    for (const userId of uniqueRecipients) {
      this.realtime.emitToUser(userId, { type: 'notification', userId });
    }

    // FCM/APNs out-of-app push. Silent no-op when Firebase isn't
    // configured. Fired in parallel with SSE so an open-app user gets
    // the SSE banner immediately while a closed-app user gets the
    // system push a moment later.
    void this.push.sendToUsers({
      userIds: uniqueRecipients,
      title: params.title,
      body: params.body ?? '',
      data: {
        type: String(params.type),
        ...Object.fromEntries(
          Object.entries(params.data ?? {}).map(([k, v]) => [k, String(v ?? '')]),
        ),
      },
    });

    // Parent fan-out — every direct student recipient generates parent
    // rows for their approved parents.
    if (!fanOut) return;

    let parentTargets: Array<{ parentId: string; studentId: string }> = [];
    try {
      const links = await this.prisma.parentChild.findMany({
        where: {
          childId: { in: uniqueRecipients },
          status: 'APPROVED' as any,
        },
        select: { parentId: true, childId: true },
      });
      parentTargets = links.map((l) => ({
        parentId: l.parentId,
        studentId: l.childId,
      }));
    } catch (e) {
      console.error('[notifications-hub] failed parent fan-out lookup:', e);
      return;
    }
    if (parentTargets.length === 0) return;

    try {
      await this.prisma.parentNotification.createMany({
        data: parentTargets.map((t) => ({
          parentId: t.parentId,
          studentId: t.studentId,
          type: String(params.type),
          title: params.title,
          message: params.body ?? null,
          data: (params.data ?? {}) as any,
        })),
      });
    } catch (e) {
      console.error('[notifications-hub] failed to persist ParentNotification rows:', e);
    }

    // Push every affected parent through the SSE bus. Distinct parents
    // only — same parent linked to two children shouldn't get two
    // pings for one event.
    const uniqueParentIds = Array.from(new Set(parentTargets.map((t) => t.parentId)));
    for (const parentId of uniqueParentIds) {
      this.parentEvents.emit({ type: 'notification.created', parentId });
    }

    // FCM/APNs out-of-app push to parents too — same fan-out, parent
    // sees the system push on their device when the app is closed.
    void this.push.sendToUsers({
      userIds: uniqueParentIds,
      title: params.title,
      body: params.body ?? '',
      data: {
        type: String(params.type),
        ...Object.fromEntries(
          Object.entries(params.data ?? {}).map(([k, v]) => [k, String(v ?? '')]),
        ),
      },
    });
  }

  /// Convenience: given an `audience` spec the way teacher endpoints
  /// already use (targetType + targetStudentIds + targetCohortIds +
  /// targetGrades), return the de-duped list of student userIds the
  /// audience resolves to in this school. Used by callers who hand
  /// over their raw audience spec instead of pre-expanding it.
  async expandAudience(opts: {
    schoolId?: string | null;
    targetType?: string | null;
    targetStudentIds?: string[];
    targetCohortIds?: string[];
    targetGrades?: number[];
  }): Promise<string[]> {
    const targetType = String(opts.targetType ?? '').toUpperCase();

    // EVERYONE → every student in the school.
    if (targetType === 'EVERYONE' || targetType === 'ALL') {
      if (!opts.schoolId) return [];
      const rows = await this.prisma.user.findMany({
        where: {
          schoolId: opts.schoolId,
          roles: { some: { role: 'STUDENT' } },
        },
        select: { id: true },
      });
      return rows.map((r) => r.id);
    }

    const out = new Set<string>();
    for (const id of opts.targetStudentIds ?? []) {
      if (id) out.add(id);
    }

    if ((opts.targetCohortIds ?? []).length > 0) {
      const rows = await this.prisma.studentCohort.findMany({
        where: { cohortId: { in: opts.targetCohortIds! } },
        select: { studentId: true },
      });
      for (const r of rows) out.add(r.studentId);
    }

    if ((opts.targetGrades ?? []).length > 0 && opts.schoolId) {
      const rows = await this.prisma.user.findMany({
        where: {
          schoolId: opts.schoolId,
          roles: { some: { role: 'STUDENT' } },
          studentProfile: { grade: { in: opts.targetGrades! } },
        },
        select: { id: true },
      });
      for (const r of rows) out.add(r.id);
    }

    return Array.from(out);
  }
}
