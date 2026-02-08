'use client';

import { useEffect, useMemo, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { parentLookup, parentMarkSeen, parentNotifications, parentUnreadCount } from '@/lib/api';
import { useParentAuth } from '@/lib/useParentAuth';

type Lookup = {
  students: { id: string; name: string }[];
  courses: { id: string; name: string; subject: string; cohortId: string }[];
};

function fmtTime(iso?: string | null) {
  if (!iso) return '';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '';
  return d.toLocaleString();
}

export default function NotificationsPage() {
  const searchParams = useSearchParams();
  const token = useParentAuth();

  const focusId = searchParams.get('focus');

  const [lookup, setLookup] = useState<Lookup>({ students: [], courses: [] });
  const [selectedStudentId, setSelectedStudentId] = useState<string | null>(null);

  const [items, setItems] = useState<any[]>([]);
  const [nextCursor, setNextCursor] = useState<string | null>(null);
  const [hasMore, setHasMore] = useState<boolean>(false);
  const [loadingMore, setLoadingMore] = useState<boolean>(false);

  const [unread, setUnread] = useState<{ unread: number; breakdown: Record<string, number> }>({ unread: 0, breakdown: {} });

  const [loading, setLoading] = useState(true);
  const [err, setErr] = useState<string | null>(null);

  const courseMap = useMemo(() => {
    const m = new Map<string, string>();
    for (const c of lookup.courses) m.set(c.id, c.name);
    return m;
  }, [lookup.courses]);

  async function loadFirstPage(studentId?: string | null) {
    const sid = studentId ?? selectedStudentId;
    const [u, n] = await Promise.all([
      parentUnreadCount({ studentId: sid || undefined }),
      parentNotifications({ studentId: sid || undefined, take: 50 }),
    ]);
    setUnread({ unread: u.unread, breakdown: u.breakdown || {} });
    setItems(n.notifications || []);
    setNextCursor(n.nextCursor ?? null);
    setHasMore(Boolean(n.nextCursor));
  }

  async function loadMore() {
    if (!hasMore || loadingMore) return;
    try {
      setLoadingMore(true);
      const sid = selectedStudentId;
      const n = await parentNotifications({ studentId: sid || undefined, take: 50, cursor: nextCursor || undefined });
      const more = n.notifications || [];
      setItems((prev) => [...prev, ...more]);
      setNextCursor(n.nextCursor ?? null);
      setHasMore(Boolean(n.nextCursor));
    } finally {
      setLoadingMore(false);
    }
  }


  useEffect(() => {
    if (!token) return;
    let mounted = true;

    (async () => {
      try {
        setErr(null);
        setLoading(true);

        const l = await parentLookup();
        if (!mounted) return;

        setLookup({ students: l.students || [], courses: l.courses || [] });

        const defaultId = l.students?.[0]?.id ?? null;

        // If we are deep-linking to a specific notification, load ALL first so it's guaranteed to exist.
        if (focusId) {
          setSelectedStudentId(null);
          await loadFirstPage(null);
        } else {
          setSelectedStudentId(defaultId);
          await loadFirstPage(defaultId);
        }

        if (focusId) {
          // wait a tick for DOM to paint
          setTimeout(() => {
            const el = document.querySelector(`[data-notif-id="${focusId}"]`);
            if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
          }, 50);
        }
      } catch (e: any) {
        if (!mounted) return;
        const msg = e?.message || String(e);
        setErr(msg);

        const lower = String(msg).toLowerCase();
        if (lower.includes('missing parent token') || lower.includes('unauthorized')) {
          window.location.href = '/login';
        }
      } finally {
        if (!mounted) return;
        setLoading(false);
      }
    })();
  // realtime notifications (SSE)
  useEffect(() => {
    try {
      const base = (process.env.NEXT_PUBLIC_API_BASE_URL || process.env.NEXT_PUBLIC_API_BASE || 'http://127.0.0.1:3000/api').replace(/\/$/, '');
      const url = base.replace(/\/api$/, '') + '/api/parent/notifications/stream';
      const t = typeof window !== 'undefined' ? (localStorage.getItem('token') || '') : '';
      const es = new EventSource(t ? `${url}?token=${encodeURIComponent(t)}` : url);

      es.onmessage = () => {
        // any event = refresh list + unread
        if (typeof refetch === 'function') refetch();
      };

      return () => es.close();
    } catch {
      // ignore (SSE unsupported)
    }
  }, []);


    return () => {
      mounted = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [token]);

  // ---- 10s polling when visible; paused when hidden ----
  useEffect(() => {
    if (!token) return;

    let alive = true;
    let interval: any = null;

    const tick = async () => {
      try {
        const sid = selectedStudentId;
        const u = await parentUnreadCount({ studentId: sid || undefined });
        setUnread({ unread: u.unread, breakdown: u.breakdown || {} });
      } catch {
        // ignore polling failures
      }
    };

    const start = () => {
      if (interval) return;
      interval = setInterval(() => { tick(); }, 10000);
    };

    const stop = () => {
      if (!interval) return;
      clearInterval(interval);
      interval = null;
    };

    const onVis = () => {
      if (document.visibilityState === 'visible') {
        tick();
        start();
      } else {
        stop();
      }
    };

    const onNotif = () => { tick(); };

    onVis();
    document.addEventListener('visibilitychange', onVis);
    window.addEventListener('classmate_parent_notifications_changed', onNotif);

    return () => {
      alive = false;
      stop();
      document.removeEventListener('visibilitychange', onVis);
      window.removeEventListener('classmate_parent_notifications_changed', onNotif);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [token, selectedStudentId]);

  async function markAllRead() {
    try {
      const ids = (items || []).filter((n) => !n.seenAt).map((n) => n.id);
      if (ids.length === 0) return;

      await parentMarkSeen({ ids });
      window.dispatchEvent(new Event('classmate_parent_notifications_changed'));

      // optimistic local update
      const now = new Date().toISOString();
      setItems((prev) => prev.map((x) => (!x.seenAt ? { ...x, seenAt: now } : x)));

      await loadFirstPage(selectedStudentId);
    } catch (e: any) {
      setErr(e?.message || String(e));
    }

  }

  async function openNotif(id: string) {
    try {
      await parentMarkSeen({ ids: [id] });
      window.dispatchEvent(new Event('classmate_parent_notifications_changed'));
      // optimistic local update
      setItems((prev) => prev.map((x) => (x.id === id ? { ...x, seenAt: new Date().toISOString() } : x)));
      await loadFirstPage(selectedStudentId);
    } catch (e: any) {
      setErr(e?.message || String(e));
    }
  }

  if (!token) return null;

  return (
    <div className="mx-auto max-w-3xl p-4">
      <div className="flex items-center justify-between gap-3">
        <h1 className="text-xl font-semibold">Notifications</h1>

        <div className="flex items-center gap-2">
          <span className="rounded-full border px-2 py-0.5 text-sm">
            Unread: <b>{unread.unread}</b>
          </span>
          <button
            onClick={markAllRead}
            className="rounded-md border px-3 py-1.5 text-sm hover:bg-black/5"
          >
            Mark all read
          </button>
        </div>
      </div>

      {Object.keys(unread.breakdown || {}).length > 0 && (
        <div className="mt-3 flex flex-wrap gap-2 text-sm">
          {Object.entries(unread.breakdown).map(([k, v]) => (
            <span key={k} className="rounded-full border px-2 py-0.5">
              {k}: <b>{v}</b>
            </span>
          ))}
        </div>
      )}

      <div className="mt-4 flex flex-wrap gap-2">
        <button
          onClick={async () => { setSelectedStudentId(null); await loadFirstPage(null); }}
          className={`rounded-full border px-3 py-1 text-sm ${selectedStudentId === null ? 'bg-black text-white' : 'hover:bg-black/5'}`}
        >
          All
        </button>
        {lookup.students.map((s) => (
          <button
            key={s.id}
            onClick={async () => { setSelectedStudentId(s.id); await loadFirstPage(s.id); }}
            className={`rounded-full border px-3 py-1 text-sm ${selectedStudentId === s.id ? 'bg-black text-white' : 'hover:bg-black/5'}`}
          >
            {s.name}
          </button>
        ))}
      </div>

      {err && (
        <div className="mt-4 rounded-md border border-red-300 bg-red-50 p-3 text-sm text-red-800">
          {err}
        </div>
      )}

      {loading ? (
        <div className="mt-6 text-sm opacity-70">Loading…</div>
      ) : (
        <div className="mt-4 space-y-2">
          {items.length === 0 ? (
            <div className="rounded-md border p-4 text-sm opacity-70">No notifications</div>
          ) : (
                      <>
            {items.map((n) => {
              const courseName =
                (n?.data?.course?.name as string | undefined) ||
                (n?.data?.courseId ? courseMap.get(n.data.courseId) : null) ||
                null;

              const isUnread = !n.seenAt;

              return (
                <button
                  data-notif-id={n.id}
                  key={n.id}
                  onClick={() => openNotif(n.id)}
                  className={`w-full rounded-md border p-3 text-left hover:bg-black/5 ${focusId === n.id ? "ring-2 ring-black/40" : ""}`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <div className="flex items-center gap-2">
                        {isUnread && <span className="inline-block h-2 w-2 rounded-full bg-blue-600" />}
                        <div className="truncate font-medium">{n.title || n.type}</div>
                      </div>

                      <div className="mt-1 text-sm opacity-80">
                        {courseName ? <span>{courseName}</span> : null}
                        {courseName ? <span className="opacity-50"> · </span> : null}
                        <span>{fmtTime(n.createdAt)}</span>
                      </div>

                      {n.message && (
                        <div className="mt-2 text-sm opacity-90">{n.message}</div>
                      )}

                      {n.type === 'ATTENDANCE_RECORDED' && n.data && (
                        <div className="mt-2 text-sm opacity-90">
                          Status: <b>{n.data.status}</b>
                          {typeof n.data.period === 'number' ? <> · Period <b>{n.data.period}</b></> : null}
                        </div>
                      )}

                      {n.type === 'GRADE_POSTED' && n.data && (
                        <div className="mt-2 text-sm opacity-90">
                          Grade: <b>{n.data.grade}</b>
                          {n.data.assessment?.title ? <> · {n.data.assessment.title}</> : null}
                        </div>
                      )}
                    </div>
                  </div>
                </button>
              );
            })}

          {hasMore && items.length > 0 ? (
            <div className="pt-2">
              <button
                onClick={loadMore}
                disabled={loadingMore}
                className="w-full rounded-md border px-3 py-2 text-sm hover:bg-black/5 disabled:opacity-60"
              >
                {loadingMore ? 'Loading…' : 'Load more'}
              </button>
            </div>
          ) : null}

          </>


          )}
        </div>
      )}
    </div>
  );
}
