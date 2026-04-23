'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParentAuth } from '@/lib/useParentAuth';
import {
  parentChildren,
  parentOverviewWeek,
  parentGrades,
  getToken,
  clearToken,
  parentUnreadCount,
  parentRecentNotifications
} from '@/lib/api';

function fmtTime(v?: string | null) {
  if (!v) return "";
  try {
    const d = new Date(v);
    return d.toLocaleString();
  } catch {
    return "";
  }
}

export default function DashboardPage() {
  const token = useParentAuth();


  const [unread, setUnread] = useState<number>(0);
  const [kids, setKids] = useState<any[]>([]);
  const [kidSummary, setKidSummary] = useState<Record<string, any>>({});
  const [recentNotifs, setRecentNotifs] = useState<any[]>([]);
  const [err, setErr] = useState<string | null>(null);

  const computeKidSummary = useMemo(() => {
    return (week: any, gradesResp: any) => {
      const sessions = week?.attendanceWeek?.sessions ?? [];
      const total = sessions.length || 0;

      const present = sessions.filter((x: any) => x.status === 'PRESENT').length;
      const late = sessions.filter((x: any) => x.status === 'LATE').length;
      const absent = sessions.filter((x: any) => x.status === 'ABSENT').length;

      const presentPct = total ? Math.round((present / total) * 100) : null;

      const grades = gradesResp?.grades ?? gradesResp ?? [];
      const scored = grades.filter((g: any) => typeof g.grade === 'number');

      const avg = scored.length
        ? Math.round(
            scored.reduce(
              (a: number, g: any) => a + g.grade,
              0
            ) / scored.length
          )
        : null;

      return { presentPct, present, late, absent, avg, total };
    };
  }, []);

  useEffect(() => {
    if (!token) return;
    let alive = true;

    const loadUnread = async () => {
      try {
        const r = await parentUnreadCount();
        if (!alive) return;
        setUnread(r?.unread ?? 0);
      } catch {
        // ignore badge failures
      }
    };

    loadUnread();

    const loadRecent = async () => {
      try {
        const r = await parentRecentNotifications(5);
        if (!alive) return;
        setRecentNotifs(r?.notifications ?? []);
      } catch {
        // ignore recent failures
      }
    };

    loadRecent();


    let interval: any = null;

    const start = () => {
      if (interval) return;
      interval = setInterval(() => { loadUnread(); loadRecent(); }, 10000);
    };
    const stop = () => {
      if (!interval) return;
      if (interval) clearInterval(interval);
      document.removeEventListener("visibilitychange", onVis);
      interval = null;
    };

    const onVis = () => {
      if (document.visibilityState === "visible") {
        loadUnread(); loadRecent();
        start();
      } else {
        stop();
      }
    };

    onVis();
    document.addEventListener("visibilitychange", onVis);

    const onToken = () => { loadUnread(); loadRecent(); };
    const onNotif = () => { loadUnread(); loadRecent(); };

    window.addEventListener('classmate_token_change', onToken);
    window.addEventListener('classmate_parent_notifications_changed', onNotif);
    const onStorage = (e: StorageEvent) => {
      if (e.key === 'parent_token') loadUnread();
    };
    window.addEventListener('storage', onStorage);

    return () => {
      alive = false;
      clearInterval(interval);
      window.removeEventListener('classmate_token_change', onToken);
      window.removeEventListener('classmate_parent_notifications_changed', onNotif);
      window.removeEventListener('storage', onStorage);
    };
  }, [token]);

  useEffect(() => {
    if (!token) return;

    ;(async () => {
      try {
        const t = getToken();
        if (!t) {
          window.location.href = '/login';
          return;
        }

        const data = await parentChildren();
        const kidsList = Array.isArray(data) ? data : [];
        setKids(kidsList);

        const entries = await Promise.all(
          kidsList.map(async (k: any) => {
            try {
              const [w, g] = await Promise.all([
                parentOverviewWeek(k.studentId),
                parentGrades(k.studentId),
              ]);
              return [k.studentId, computeKidSummary(w, g)];
            } catch {
              return [k.studentId, { error: true }];
            }
          })
        );

        setKidSummary(Object.fromEntries(entries));
        setErr(null);
      } catch (e: any) {
        setErr(e?.message ?? 'Failed to load');
      }
    })();
  }, [token, computeKidSummary]);

  // ✅ Render guard AFTER hooks
  if (!token) {
    return (
      <main className="min-h-screen p-6 max-w-3xl mx-auto">
        <div className="rounded-lg border p-4 text-sm opacity-80">
          Loading dashboard…
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Parent Dashboard</h1>
        <button
          className="rounded-md border px-3 py-2 text-sm"
          onClick={() => {
            clearToken();
            window.location.href = '/login';
          }}
        >
          Logout
        </button>
      </div>

      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}


      <section className="mt-4 rounded-lg border p-4">
        <div className="flex items-center justify-between gap-3">
          <h2 role="heading" aria-level={2} className="text-sm font-semibold">Recent alerts</h2>
          <Link className="text-sm underline opacity-80" href="/notifications">View all</Link>
        </div>

        {recentNotifs.length === 0 ? (
          <div className="mt-3 text-sm opacity-70">No recent alerts</div>
        ) : (
          <div className="mt-3 space-y-2">
            {recentNotifs.slice(0, 5).map((n: any) => (
              <Link
                key={n.id}
                href={`/notifications?focus=${encodeURIComponent(n.id)}`}
                className="block rounded-md border p-3 text-sm hover:bg-black/5"
              >
                <div className="flex items-center justify-between gap-3">
                  <div className="min-w-0">
                    <div className="truncate font-medium">{n.title || n.type}</div>
                    <div className="mt-1 truncate opacity-70">{n.type}</div>
                  </div>

                  <div className="flex items-center gap-2">
                    <span className="text-xs opacity-60">
                      {fmtTime(n.createdAt)}
                    </span>
                    {!n.seenAt ? (
                      <span className="rounded-full border px-2 py-0.5 text-xs">New</span>
                    ) : null}
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </section>


      <section className="mt-6">
        <h2 className="font-semibold">Children</h2>

        <div className="mt-2 space-y-2">
          {kids.map((k) => (
            <Link
              key={k.studentId}
              href={`/child/${k.studentId}`}
              className="block rounded-lg border p-3 hover:bg-black/5"
            >
              <div className="font-medium">{k.name}</div>
              <div className="text-sm opacity-70">
                {k.cohort?.name} · Grade {k.cohort?.grade} · {k.status}
              </div>

              <div className="text-sm opacity-70 mt-1">
                {kidSummary[k.studentId]?.error ? (
                  <span>Summary unavailable</span>
                ) : (
                  <>
                    <span>
                      Attendance: {kidSummary[k.studentId]?.presentPct ?? '—'}%
                      {kidSummary[k.studentId]?.total ? (
                        <>
                          {' '}
                          (P {kidSummary[k.studentId].present} · L{' '}
                          {kidSummary[k.studentId].late} · A{' '}
                          {kidSummary[k.studentId].absent})
                        </>
                      ) : null}
                    </span>
                    <span>
                      {' '}
                      · Avg grade: {kidSummary[k.studentId]?.avg ?? '—'}%
                    </span>
                  </>
                )}
              </div>
            </Link>
          ))}

          {kids.length === 0 && (
            <div className="opacity-70">
              No children linked yet. Ask the school for a parent link code.
            </div>
          )}
        </div>
      </section>

      <div className="mt-6">
        <Link className="text-sm underline opacity-80" href="/notifications"><span className="flex items-center gap-2">Notifications{unread > 0 ? (
              <span className="rounded-full bg-black/10 px-2 py-0.5 text-xs font-medium">
                {unread}
              </span>
            ) : null}</span></Link>
      </div>
    </main>
  );
}
