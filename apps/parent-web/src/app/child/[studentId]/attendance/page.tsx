'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { parentOverviewWeek } from '@/lib/api';
import { useParentAuth } from '@/lib/useParentAuth';

export default function AttendancePage() {
  const token = useParentAuth();
  const { studentId } = useParams<{ studentId: string }>();

  const [week, setWeek] = useState<any>(null);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    if (!token) return;
    (async () => {
      try {
        const w = await parentOverviewWeek(studentId);
        setWeek(w);
      } catch (e: any) {
        setErr(e?.message ?? 'Failed to load attendance');
      }
    })();
  }, [studentId, token]);

  const sessions = week?.attendanceWeek?.sessions ?? [];

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Attendance</h1>
        <Link
          className="rounded-md border px-3 py-2 text-sm"
          href={`/child/${studentId}`}
        >
          Back
        </Link>
      </div>

      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}

      <div className="mt-6 space-y-2">
        {sessions.map((s: any, i: number) => (
          <div key={i} className="rounded-lg border p-3">
            <div className="font-medium">
              {s.date} · Period {s.period}
            </div>
            <div className="text-sm opacity-70">
              {s.course?.name ?? 'Unknown'} · {s.status}
            </div>
          </div>
        ))}

        {sessions.length === 0 && !err && (
          <div className="opacity-70">No attendance records this week.</div>
        )}
      </div>
    </main>
  );
}
