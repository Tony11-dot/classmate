'use client';

import { useEffect, useState } from 'react';
import { useParentAuth } from '@/lib/useParentAuth';
import Link from 'next/link';
import { parentNotifications, parentUnreadCount, parentMarkSeen } from '@/lib/api';

function fmt(ts?: string) {
  if (!ts) return '';
  return new Date(ts).toLocaleString();
}

export default function NotificationsPage() {
  const token = useParentAuth();
  const [rows, setRows] = useState<any[]>([]);
  const [unread, setUnread] = useState<any>(null);
  const [err, setErr] = useState<string | null>(null);

  async function load() {
    if (!token) return;
    setErr(null);
    try {
      const [n, u] = await Promise.all([
        parentNotifications(20),
        parentUnreadCount(),
      ]);
      setRows(n?.notifications ?? []);
      setUnread(u);
    } catch (e: any) {
      setErr(e?.message ?? 'Failed to load');
    }
  }

  useEffect(() => { if (token) load(); }, [token]);

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Notifications</h1>
        <div className="flex gap-2">
          <button className="rounded-md border px-3 py-2 text-sm" onClick={load}>
            Refresh
          </button>
          <Link className="rounded-md border px-3 py-2 text-sm" href="/dashboard">
            Back
          </Link>
        </div>
      </div>

      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}

      {unread && (
        <div className="mt-4 rounded-lg border p-3 text-sm">
          <div>
            Unread: <span className="font-medium">{unread.unread}</span>
          </div>
          <div className="opacity-70 text-xs">
            Since {fmt(unread.since)}
          </div>
          <button
            className="mt-2 rounded-md border px-3 py-2 text-sm"
            onClick={async () => { await parentMarkSeen(); await load(); }}
          >
            Mark all as seen
          </button>
        </div>
      )}

      <div className="mt-6 space-y-3">
        {rows.map((n, i) => (
          <div key={i} className="rounded-lg border p-3">
            <div className="font-medium">
              {n.title ?? n.type}
            </div>
            <div className="text-sm opacity-70">
              {fmt(n.at)} · {n.studentName}
            </div>

            {n.type === 'ATTENDANCE_MARKED' && (
              <div className="mt-2 text-sm">
                Period {n.data?.period} · {n.data?.status}
                {n.data?.course && (
                  <span className="opacity-70">
                    {' '}· {n.data.course.name}
                  </span>
                )}
              </div>
            )}

            {n.type === 'GRADE_UPDATED' && (
              <div className="mt-2 text-sm">
                Grade updated · {n.data?.assessmentName}
              </div>
            )}
          </div>
        ))}

        {rows.length === 0 && !err && (
          <div className="opacity-70">No notifications.</div>
        )}
      </div>
    </main>
  );
}
