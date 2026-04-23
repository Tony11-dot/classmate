'use client';

import { useEffect, useMemo, useState } from 'react';

import { AdminShell } from '@/components/AdminShell';
import { RequireAuth } from '@/components/RequireAuth';
import { apiFetch } from '@/lib/api';

type TodaySlot = {
  period: number;
  source: 'TEMPLATE' | 'OVERRIDE' | 'EMPTY';
  cohort?: { id: string; name: string; grade: number } | null;
  course?: { id: string; name: string; subject: string } | null;
};

type TodayResponse = {
  ok: true;
  date: string;
  dayOfWeek: number;
  slots: TodaySlot[];
};

type Course = {
  id: string;
  name: string;
  subject: string;
  cohortId: string | null;
};

type Assessment = {
  id: string;
  courseId: string;
  title: string;
  date: string;
  maxGrade?: number | null;
};

type AssessmentsResponse = { ok: true; courses: Course[]; assessments: Assessment[] };

function fmtDate(value: string) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toISOString().slice(0, 10);
}

export default function Home() {
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [today, setToday] = useState<TodayResponse | null>(null);
  const [courses, setCourses] = useState<Course[]>([]);
  const [assessments, setAssessments] = useState<Assessment[]>([]);

  useEffect(() => {
    let active = true;
    (async () => {
      setLoading(true);
      setErr(null);
      try {
        const [todayRes, assessmentsRes] = await Promise.all([
          apiFetch<TodayResponse>('/teacher/schedule/today'),
          apiFetch<AssessmentsResponse>('/teacher/grades/assessments'),
        ]);
        if (!active) return;
        setToday(todayRes);
        setCourses(assessmentsRes.courses ?? []);
        setAssessments(assessmentsRes.assessments ?? []);
      } catch (error) {
        if (!active) return;
        setErr(error instanceof Error ? error.message : 'Failed to load dashboard');
      } finally {
        if (active) setLoading(false);
      }
    })();
    return () => {
      active = false;
    };
  }, []);

  const upcoming = useMemo(
    () => [...assessments].sort((left, right) => left.date.localeCompare(right.date)).slice(0, 5),
    [assessments],
  );

  const teachingGroups = useMemo(
    () => new Set(courses.map((course) => course.cohortId).filter(Boolean)).size,
    [courses],
  );

  const scheduledToday = useMemo(
    () => (today?.slots ?? []).filter((slot) => slot.course && slot.cohort).length,
    [today],
  );

  return (
    <RequireAuth>
      <AdminShell>
        <div className="teacher-page">
          <div className="flex items-start justify-between gap-4">
            <div>
              <div className="teacher-kicker">Dashboard</div>
              <h1 className="mt-2 text-3xl font-semibold">Run the day from one place</h1>
              <p className="teacher-muted mt-2 text-sm">
                Start from today, then move into classrooms and assessments without switching context.
              </p>
            </div>
            {loading ? <div className="teacher-muted text-sm">Loading…</div> : null}
          </div>

          {err ? (
            <div className="rounded-2xl border border-red-200 bg-red-50 p-3 text-sm text-red-700">{err}</div>
          ) : null}

          <section className="grid gap-4 md:grid-cols-4">
            <div className="teacher-metric rounded-3xl p-4">
              <div className="teacher-kicker">Teaching groups</div>
              <div className="mt-2 text-3xl font-semibold">{teachingGroups}</div>
            </div>
            <div className="teacher-metric rounded-3xl p-4">
              <div className="teacher-kicker">Courses</div>
              <div className="mt-2 text-3xl font-semibold">{courses.length}</div>
            </div>
            <div className="teacher-metric rounded-3xl p-4">
              <div className="teacher-kicker">Assessments</div>
              <div className="mt-2 text-3xl font-semibold">{assessments.length}</div>
            </div>
            <div className="teacher-metric rounded-3xl p-4">
              <div className="teacher-kicker">Sessions today</div>
              <div className="mt-2 text-3xl font-semibold">{scheduledToday}</div>
            </div>
          </section>

          <section className="grid gap-6 lg:grid-cols-[1.2fr_0.8fr]">
            <div className="teacher-panel rounded-[1.75rem] p-5">
              <div className="flex items-center justify-between">
                <h2 className="text-lg font-semibold">Today</h2>
                <span className="teacher-muted text-sm">{today?.date ?? 'No date'}</span>
              </div>
              <div className="mt-4 space-y-3">
                {(today?.slots ?? []).length === 0 ? (
                  <div className="teacher-muted text-sm">No teaching slots scheduled today.</div>
                ) : (
                  today?.slots.map((slot) => (
                    <div key={`${slot.period}-${slot.cohort?.id ?? 'free'}`} className="rounded-2xl border border-slate-200/80 bg-white/70 p-3">
                      <div className="flex items-center justify-between gap-3">
                        <div>
                          <div className="font-medium">Period {slot.period}</div>
                          <div className="teacher-muted mt-1 text-sm">
                            {slot.course ? `${slot.course.name} · ${slot.course.subject}` : 'Unassigned slot'}
                          </div>
                        </div>
                        <div className="teacher-muted text-right text-sm">
                          {slot.cohort ? `${slot.cohort.name} · Grade ${slot.cohort.grade}` : 'No cohort'}
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>

            <div className="teacher-panel rounded-[1.75rem] p-5">
              <h2 className="text-lg font-semibold">Upcoming assessments</h2>
              <div className="mt-4 space-y-3">
                {upcoming.length === 0 ? (
                  <div className="teacher-muted text-sm">No assessments created yet.</div>
                ) : (
                  upcoming.map((assessment) => {
                    const course = courses.find((item) => item.id === assessment.courseId);
                    return (
                      <div key={assessment.id} className="rounded-2xl border border-slate-200/80 bg-white/70 p-3">
                        <div className="font-medium">{assessment.title}</div>
                        <div className="teacher-muted mt-1 text-sm">
                          {course?.name ?? 'Course'} · {fmtDate(assessment.date)}
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            </div>
          </section>
        </div>
      </AdminShell>
    </RequireAuth>
  );
}
