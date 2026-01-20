'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { parentNotifications, parentUnreadCount, parentMarkSeen } from '@/lib/api';

export default function NotificationsPage() {
  const [rows, setRows] = useState<any[]>([]);
  const [unread, setUnread] = useState<any>(null);
  const [err, setErr] = useState<string | null>(null);

  async function load() {
    setErr(null);
    try {
      const [n, u] = await Promise.all([parentNotifications(20), parentUnreadCount()]);
      setRows(n?.notifications ?? []);
      setUnread(u);
    } catch (e: any) {
      setErr(e?.message ?? 'Failed to load');
    }
  }

  useEffect(() => { load(); }, []);

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Notifications</h1>
        <div className="flex gap-2">
          <button className="rounded-md border px-3 py-2 text-sm" onClick={load}>Refresh</button>
          <Link className="rounded-md border px-3 py-2 text-sm" href="/dashboard">Back</Link>
        </div>
      </div>

      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}

      {unread && (
        <div className="mt-4 rounded-lg border p-3 text-sm">
          Unread: <span className="font-medium">{unread.unread}</span>
          <span className="opacity-70"> · since {unread.since}</span>
          <div className="opacity-70">breakdown: {JSON.stringify(unread.breakdown)}</div>
          <button
            className="mt-2 rounded-md border px-3 py-2 text-sm"
            onClick={async () => { await parentMarkSeen(); await load(); }}
          >
            Mark seen
          </button>
        </div>
      )}

      <div className="mt-4 space-y-2">
        {rows.map((n, i) => (
          <div key={i} className="rounded-lg border p-3">
            <div className="font-medium">{n.title ?? n.type}</div>
            <div className="text-sm opacity-70">{n.at} · {n.studentName} ({n.studentId})</div>
            <pre className="mt-2 text-xs overflow-auto">{JSON.stringify(n.data ?? n, null, 2)}</pre>
          </div>
        ))}
        {rows.length === 0 && !err && <div className="opacity-70">No notifications.</div>}
      </div>
    </main>
  );
}
