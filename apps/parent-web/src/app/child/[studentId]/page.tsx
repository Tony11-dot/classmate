'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { parentOverview, parentOverviewWeek } from '@/lib/api';

function fmtDate(d?: string) {
  if (!d) return '';
  return new Date(d).toLocaleDateString();
}

export default function ChildPage() {
  const { studentId } = useParams<{ studentId: string }>();
  const [today, setToday] = useState<any>(null);
  const [week, setWeek] = useState<any>(null);
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const [t, w] = await Promise.all([
          parentOverview(studentId),
          parentOverviewWeek(studentId),
        ]);
        setToday(t);
        setWeek(w);
      } catch (e: any) {
        setErr(e?.message ?? 'Failed to load');
      }
    })();
  }, [studentId]);

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold">
            {today?.student?.name ?? 'Student'}
          </h1>
          <div className="text-sm opacity-70">
            Cohort {today?.cohortId}
          </div>
        </div>
        <Link className="rounded-md border px-3 py-2 text-sm" href="/dashboard">
          Back
        </Link>
      </div>

      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}

      {/* Today */}
      <section className="mt-6">
        <h2 className="font-semibold">Today</h2>

        <div className="mt-2 space-y-2">
          {today?.todaySchedule?.slots?.map((s: any) => (
            <div key={s.period} className="rounded-lg border p-3">
              <div className="font-medium">
                Period {s.period}
              </div>
              <div className="text-sm opacity-70">
                {s.course
                  ? `${s.course.name} · ${s.course.subject}`
                  : 'Free'}
              </div>
            </div>
          ))}
          {(!today?.todaySchedule?.slots?.length) && (
            <div className="opacity-70">No schedule today.</div>
          )}
        </div>

        <div className="mt-4">
          <h3 className="font-medium">Attendance</h3>
          <div className="mt-2 space-y-2">
            {today?.todayAttendance?.sessions?.map((a: any, i: number) => (
              <div key={i} className="rounded-lg border p-3">
                Period {a.period} · {a.status}
                {a.course && (
                  <div className="text-sm opacity-70">
                    {a.course.name}
                  </div>
                )}
              </div>
            ))}
            {(!today?.todayAttendance?.sessions?.length) && (
              <div className="opacity-70">No attendance records.</div>
            )}
          </div>
        </div>
      </section>

      {/* Week */}
      <section className="mt-6">
        <h2 className="font-semibold">This Week</h2>
        <div className="text-sm opacity-70">
          {fmtDate(week?.weekSchedule?.weekStart)} – {fmtDate(week?.weekSchedule?.weekEnd)}
        </div>

        <div className="mt-2 space-y-2">
          {week?.attendanceWeek?.sessions?.map((s: any, i: number) => (
            <div key={i} className="rounded-lg border p-3">
              <div className="font-medium">
                {fmtDate(s.date)} · Period {s.period}
              </div>
              <div className="text-sm opacity-70">
                {s.course?.name} · {s.status}
              </div>
            </div>
          ))}
          {(!week?.attendanceWeek?.sessions?.length) && (
            <div className="opacity-70">No attendance this week.</div>
          )}
        </div>
      </section>
    </main>
  );
}
