import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RealtimeService } from '../realtime/realtime.service';
import { ParentNotificationsEvents } from '../parent/parent-notifications.events';
import { PushService } from './push.service';
import {
  NotifTemplate,
  NotifLocale,
  normalizeLocale,
  renderNotif,
} from './notif-i18n';

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

  /// Headline copy (max ~60 chars). Used as the fallback when no
  /// `template` is supplied (legacy callers) or for users with no stored
  /// language.
  title: string;

  /// Optional longer body. Markdown not rendered — plain text only.
  body?: string;

  /// Preferred path: a localizable template (`key` + `args`). When present,
  /// the hub renders title/body PER RECIPIENT in that user's stored
  /// `language` — so each person (and each parent) reads the event in their
  /// own language, in both the in-app inbox and the system push. Falls back
  /// to `title`/`body` above when absent.
  template?: NotifTemplate;

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

    // Per-recipient language (only needed when localizing via a template).
    const recipientLang = params.template
      ? await this.languagesFor(uniqueRecipients)
      : new Map<string, NotifLocale>();

    try {
      // Persist the recipient rows — title/body rendered in each user's language.
      const data = uniqueRecipients.map((userId) => {
        const { title, body } = this.copyFor(params, recipientLang.get(userId));
        return {
          userId,
          type: String(params.type),
          title,
          body: body ?? null,
          data: (params.data ?? {}) as any,
          severity: params.severity ?? 'info',
        };
      });
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
    // system push a moment later. Grouped by language so each device
    // shows the copy in its owner's language.
    void this.pushLocalized(uniqueRecipients, params, recipientLang);

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
    // Inbox parity: parents who are DIRECT recipients (whole-school broadcast
    // or PARENT-role-targeted announcements) — and didn't already get a row
    // via the student fan-out above — also get a parent-notification row, so
    // the in-app inbox matches the system push they received. studentId is
    // null (it's about them, not a specific child).
    try {
      const fanned = new Set(parentTargets.map((t) => t.parentId));
      const directParents = await this.prisma.user.findMany({
        where: {
          id: { in: uniqueRecipients },
          roles: { some: { role: 'PARENT' as any } },
        },
        select: { id: true },
      });
      const directParentIds = directParents
        .map((u) => u.id)
        .filter((id) => !fanned.has(id));
      if (directParentIds.length > 0) {
        // These parents are also direct recipients, so they already share
        // the recipient language map.
        await this.prisma.parentNotification.createMany({
          data: directParentIds.map((pid) => {
            const { title, body } = this.copyFor(params, recipientLang.get(pid));
            return {
              parentId: pid,
              studentId: null,
              type: String(params.type),
              title,
              message: body ?? null,
              data: (params.data ?? {}) as any,
            };
          }),
        });
        for (const pid of directParentIds) {
          this.parentEvents.emit({ type: 'notification.created', parentId: pid });
        }
      }
    } catch (e) {
      console.error('[notifications-hub] failed direct-parent fan-out:', e);
    }

    if (parentTargets.length === 0) return;

    const uniqueParentIds = Array.from(new Set(parentTargets.map((t) => t.parentId)));
    const parentLang = params.template
      ? await this.languagesFor(uniqueParentIds)
      : new Map<string, NotifLocale>();

    try {
      await this.prisma.parentNotification.createMany({
        data: parentTargets.map((t) => {
          const { title, body } = this.copyFor(params, parentLang.get(t.parentId));
          return {
            parentId: t.parentId,
            studentId: t.studentId,
            type: String(params.type),
            title,
            message: body ?? null,
            data: (params.data ?? {}) as any,
          };
        }),
      });
    } catch (e) {
      console.error('[notifications-hub] failed to persist ParentNotification rows:', e);
    }

    // Push every affected parent through the SSE bus. Distinct parents
    // only — same parent linked to two children shouldn't get two
    // pings for one event.
    for (const parentId of uniqueParentIds) {
      this.parentEvents.emit({ type: 'notification.created', parentId });
    }

    // FCM/APNs out-of-app push to parents too — same fan-out, parent
    // sees the system push on their device when the app is closed, in
    // their own language.
    void this.pushLocalized(uniqueParentIds, params, parentLang);
  }

  /// Load each user's stored UI language, normalized to a supported locale.
  /// Missing rows / null languages default to English at render time.
  private async languagesFor(ids: string[]): Promise<Map<string, NotifLocale>> {
    const out = new Map<string, NotifLocale>();
    const unique = Array.from(new Set(ids.filter(Boolean)));
    if (unique.length === 0) return out;
    try {
      const rows = await this.prisma.user.findMany({
        where: { id: { in: unique } },
        select: { id: true, language: true } as any,
      });
      for (const r of rows as any[]) {
        out.set(r.id, normalizeLocale(r.language));
      }
    } catch (e) {
      console.error('[notifications-hub] failed to load recipient languages:', e);
    }
    return out;
  }

  /// Resolve the title/body for one recipient: render the template in their
  /// language when present, otherwise fall back to the literal title/body.
  private copyFor(
    params: NotifyParams,
    locale?: NotifLocale,
  ): { title: string; body: string } {
    if (params.template) {
      return renderNotif(params.template, locale ?? 'en');
    }
    return { title: params.title, body: params.body ?? '' };
  }

  /// Send the FCM/APNs push to a set of users, grouped by language so every
  /// device gets the copy in its owner's language. Falls back to a single
  /// send when there is no template.
  private async pushLocalized(
    userIds: string[],
    params: NotifyParams,
    langMap: Map<string, NotifLocale>,
  ): Promise<void> {
    const ids = Array.from(new Set(userIds.filter(Boolean)));
    if (ids.length === 0) return;

    const dataPayload = {
      type: String(params.type),
      ...Object.fromEntries(
        Object.entries(params.data ?? {}).map(([k, v]) => [k, String(v ?? '')]),
      ),
    };

    if (!params.template) {
      await this.push.sendToUsers({
        userIds: ids,
        title: params.title,
        body: params.body ?? '',
        data: dataPayload,
      });
      return;
    }

    // Bucket recipients by locale and send one multicast per language.
    const byLocale = new Map<NotifLocale, string[]>();
    for (const id of ids) {
      const loc = langMap.get(id) ?? 'en';
      const bucket = byLocale.get(loc) ?? [];
      bucket.push(id);
      byLocale.set(loc, bucket);
    }
    for (const [loc, group] of byLocale.entries()) {
      const { title, body } = renderNotif(params.template, loc);
      await this.push.sendToUsers({
        userIds: group,
        title,
        body,
        data: dataPayload,
      });
    }
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
    const hasNarrowTargets =
      (opts.targetStudentIds?.length ?? 0) > 0 ||
      (opts.targetCohortIds?.length ?? 0) > 0 ||
      (opts.targetGrades?.length ?? 0) > 0;

    // EVERYONE → every student in the school, BUT only when there is no
    // narrower targeting. A grade/cohort/student-scoped item that the create
    // screen stored as EVERYONE (because it never sends a precise type for a
    // grade-only selection) must NOT blast the whole school — fall through to
    // the narrower resolution below. Mirrors the in-app read-path gating.
    if ((targetType === 'EVERYONE' || targetType === 'ALL') && !hasNarrowTargets) {
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
