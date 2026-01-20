'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { parentOverview, parentOverviewWeek } from '@/lib/api';

export default function ChildPage() {
  const params = useParams<{ studentId: string }>();
  const studentId = params.studentId;

  const [today, setToday] = useState<any>(null);
  const [week, setWeek] = useState<any>(null);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const a = await parentOverview(studentId);
        const b = await parentOverviewWeek(studentId);
        setToday(a);
        setWeek(b);
      } catch (e: any) {
        setErr(e?.message ?? 'Failed to load');
      }
    })();
  }, [studentId]);

  const slots = today?.todaySchedule?.slots ?? [];
  const sessions = today?.todayAttendance?.sessions ?? [];

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold">Child Overview</h1>
          <div className="text-sm opacity-70">{studentId}</div>
        </div>
        <Link className="rounded-md border px-3 py-2 text-sm" href="/dashboard">Back</Link>
      </div>

      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}

      <section className="mt-6">
        <h2 className="font-semibold">Today schedule</h2>
        <div className="mt-2 space-y-2">
          {slots.map((s: any) => (
            <div key={s.period} className="rounded-lg border p-3">
              <div className="font-medium">Period {s.period}</div>
              <div className="text-sm opacity-70">
                {s.course ? `${s.course.name} · ${s.course.subject}` : 'Free'}
              </div>
            </div>
          ))}
          {slots.length === 0 && <div className="opacity-70">No slots today.</div>}
        </div>
      </section>

      <section className="mt-6">
        <h2 className="font-semibold">Today attendance</h2>
        <div className="mt-2 space-y-2">
          {sessions.map((x: any, i: number) => (
            <div key={`${x.period}-${i}`} className="rounded-lg border p-3">
              <div className="font-medium">Period {x.period} · {x.status}</div>
              <div className="text-sm opacity-70">
                {x.course ? `${x.course.name} · ${x.course.subject}` : 'Unknown'}{x.note ? ` · ${x.note}` : ''}
              </div>
            </div>
          ))}
          {sessions.length === 0 && <div className="opacity-70">No attendance records today.</div>}
        </div>
      </section>

      <section className="mt-6">
        <h2 className="font-semibold">Week (raw)</h2>
        <pre className="mt-2 rounded-lg border p-3 text-xs overflow-auto">{JSON.stringify(week, null, 2)}</pre>
      </section>
    </main>
  );
}
