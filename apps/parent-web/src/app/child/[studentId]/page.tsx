'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { useParentAuth } from '@/lib/useParentAuth';
import { parentOverview, parentOverviewWeek, parentGrades } from '@/lib/api';

function fmtDate(d?: string) {
  if (!d) return '';
  return new Date(d).toLocaleDateString();
}

function gradeLabel(g: any) {
  if (typeof g?.grade === 'number') return `${g.grade}%`;
  return '—';
}

export default function ChildPage() {
  const token = useParentAuth();
  const { studentId } = useParams<{ studentId: string }>();

  const [today, setToday] = useState<any>(null);
  const [week, setWeek] = useState<any>(null);
  const [grades, setGrades] = useState<any[]>([]);
  const [summary, setSummary] = useState<any>(null);
  const [err, setErr] = useState<string | null>(null);

  const computeSummary = useMemo(() => {
    return (weekData: any, gradesList: any[]) => {
      const sessions = weekData?.attendanceWeek?.sessions ?? [];
      const total = sessions.length || 0;

      const late = sessions.filter((x: any) => x.status === 'LATE').length;
      const absent = sessions.filter((x: any) => x.status === 'ABSENT').length;
      const present = sessions.filter((x: any) => x.status === 'PRESENT').length;

      const pct = total ? Math.round((present / total) * 100) : null;

      const scored = (gradesList ?? []).filter(
        (g: any) => typeof g.grade === 'number'
      );

      const avg = scored.length
        ? Math.round(
            scored.reduce(
              (a: number, g: any) => a + g.grade,
              0
            ) / scored.length
          )
        : null;

      return { pct, late, absent, avg };
    };
  }, []);

  useEffect(() => {
    if (!token) return;
    if (!studentId) return;

    ;(async () => {
      try {
        const [t, w, g] = await Promise.all([
          parentOverview(studentId),
          parentOverviewWeek(studentId),
          parentGrades(studentId),
        ]);

        setToday(t);
        setWeek(w);
        setGrades(Array.isArray(g?.grades) ? g.grades : Array.isArray(g) ? g : []);
        const gg = Array.isArray(g?.grades) ? g.grades : Array.isArray(g) ? g : [];
        setSummary(computeSummary(w, gg));
        setErr(null);
      } catch (e: any) {
        setErr(e?.message ?? 'Failed to load');
      }
    })();
  }, [token, studentId, computeSummary]);

  // ✅ Render guard AFTER hooks
  if (!token) {
    return (
      <main className="min-h-screen p-6 max-w-3xl mx-auto">
        <div className="rounded-lg border p-4 text-sm opacity-80">
          Loading child overview…
        </div>
      </main>
    );
  }

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold">{today?.student?.name ?? 'Student'}</h1>
          <div className="text-sm opacity-70">
            {week?.weekSchedule?.weekStart ? (
              <>
                Week: {fmtDate(week.weekSchedule.weekStart)} – {fmtDate(week.weekSchedule.weekEnd)}
              </>
            ) : (
              <>Student overview</>
            )}
          </div>
        </div>

        <Link className="rounded-md border px-3 py-2 text-sm" href="/dashboard">
          Back
        </Link>
      </div>

      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}

      {summary && (
        <div className="mt-4 rounded-lg border p-3 text-sm opacity-80">
          Attendance: {summary.pct ?? '—'}% · Lates: {summary.late ?? '—'} · Absences:{' '}
          {summary.absent ?? '—'} · Avg grade: {summary.avg ?? '—'}%
        </div>
      )}

      {/* Today */}
      <section className="mt-6">
        <h2 className="font-semibold">Today</h2>

        <div className="mt-2 space-y-2">
          {today?.todaySchedule?.slots?.map((s: any) => (
            <div key={s.period} className="rounded-lg border p-3">
              <div className="font-medium">Period {s.period}</div>
              <div className="text-sm opacity-70">
                {s.course ? `${s.course.name} · ${s.course.subject}` : 'Free'}
              </div>
            </div>
          ))}

          {!today?.todaySchedule?.slots?.length && (
            <div className="opacity-70">No schedule today.</div>
          )}
        </div>

        <div className="mt-4">
          <h3 className="font-medium">Attendance</h3>
          <div className="mt-2 space-y-2">
            {today?.todayAttendance?.sessions?.map((a: any, i: number) => (
              <div key={i} className="rounded-lg border p-3">
                Period {a.period} · {a.status}
                {a.course && <div className="text-sm opacity-70">{a.course.name}</div>}
              </div>
            ))}

            {!today?.todayAttendance?.sessions?.length && (
              <div className="opacity-70">No attendance records.</div>
            )}
          </div>
        </div>
      </section>

      {/* Week */}
      <section className="mt-6">
        <h2 className="font-semibold">This Week</h2>

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

          {!week?.attendanceWeek?.sessions?.length && (
            <div className="opacity-70">No attendance this week.</div>
          )}
        </div>
      </section>

      {/* Grades (optional quick list) */}
      <section className="mt-6">
        <h2 className="font-semibold">Grades</h2>
        <div className="mt-2 space-y-2">
          {grades.slice(0, 10).map((g: any, i: number) => (
            <div key={i} className="rounded-lg border p-3">
              <div className="font-medium">{g.assessment?.title ?? 'Assessment'}</div>
              <div className="text-sm opacity-70">
                {gradeLabel(g)}
                {g.course?.name ? ` · ${g.course.name}` : ''}
              </div>
            </div>
          ))}
          {grades.length === 0 && <div className="opacity-70">No grades.</div>}
        </div>
      </section>
    </main>
  );
}
