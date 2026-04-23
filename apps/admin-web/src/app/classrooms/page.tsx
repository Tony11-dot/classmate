'use client';

import { useEffect, useMemo, useState } from 'react';

import { AdminShell } from '@/components/AdminShell';
import { RequireAuth } from '@/components/RequireAuth';
import { apiFetch, fetchCohortStudents, type CohortStudent } from '@/lib/api';

type Course = {
  id: string;
  name: string;
  subject: string;
  cohortId: string | null;
};

type AssessmentsResponse = { ok: true; courses: Course[]; assessments: unknown[] };

type JoinCodeResponse = {
  cohortId: string;
  code: string;
  expiresAt?: string | null;
};

export default function ClassroomsPage() {
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [courses, setCourses] = useState<Course[]>([]);
  const [selectedCohortId, setSelectedCohortId] = useState<string | null>(null);
  const [students, setStudents] = useState<CohortStudent[]>([]);
  const [joinCode, setJoinCode] = useState<JoinCodeResponse | null>(null);
  const [joinCodeBusy, setJoinCodeBusy] = useState(false);

  useEffect(() => {
    let active = true;
    (async () => {
      setLoading(true);
      setErr(null);
      try {
        const res = await apiFetch<AssessmentsResponse>('/teacher/grades/assessments');
        if (!active) return;
        setCourses(res.courses ?? []);
      } catch (error) {
        if (!active) return;
        setErr(error instanceof Error ? error.message : 'Failed to load classrooms');
      } finally {
        if (active) setLoading(false);
      }
    })();
    return () => {
      active = false;
    };
  }, []);

  const cohorts = useMemo(() => {
    const map = new Map<string, { cohortId: string; courses: Course[] }>();
    for (const course of courses) {
      if (!course.cohortId) continue;
      if (!map.has(course.cohortId)) {
        map.set(course.cohortId, { cohortId: course.cohortId, courses: [] });
      }
      map.get(course.cohortId)!.courses.push(course);
    }
    return Array.from(map.values());
  }, [courses]);

  async function openCohort(cohortId: string) {
    setSelectedCohortId(cohortId);
    setJoinCode(null);
    setErr(null);
+    setStudents([]);
    try {
      const res = await fetchCohortStudents(cohortId);
      setStudents(res.students ?? []);
    } catch (error) {
      setErr(error instanceof Error ? error.message : 'Failed to load classroom roster');
    }
  }

  async function generateJoinCode() {
    if (!selectedCohortId) return;
    setJoinCodeBusy(true);
    setErr(null);
    try {
      const res = await apiFetch<JoinCodeResponse>('/teacher/cohorts/join-code', {
        method: 'POST',
        body: JSON.stringify({ cohortId: selectedCohortId, expiresInHours: 24, length: 6 }),
      });
      setJoinCode(res);
    } catch (error) {
      setErr(error instanceof Error ? error.message : 'Failed to create join code');
    } finally {
      setJoinCodeBusy(false);
    }
  }

  const selectedCourses = cohorts.find((cohort) => cohort.cohortId === selectedCohortId)?.courses ?? [];

  return (
    <RequireAuth>
      <AdminShell>
        <div className="teacher-page">
          <div className="flex items-start justify-between gap-4">
            <div>
              <div className="teacher-kicker">Classrooms</div>
              <h1 className="mt-2 text-3xl font-semibold">Open rosters and move students in cleanly</h1>
              <p className="teacher-muted mt-2 text-sm">
                Open a teaching group, review the student roster, and create a join code to let students enter the right classroom.
              </p>
            </div>
            {loading ? <div className="teacher-muted text-sm">Loading…</div> : null}
          </div>

          {err ? (
            <div className="rounded border border-red-200 bg-red-50 p-3 text-sm text-red-700">{err}</div>
          ) : null}

          <div className="grid gap-6 lg:grid-cols-[0.9fr_1.1fr]">
            <section className="teacher-panel rounded-[1.75rem] p-5">
              <h2 className="text-lg font-semibold">Teaching groups</h2>
              <div className="mt-4 space-y-3">
                {cohorts.length === 0 ? (
                  <div className="teacher-muted text-sm">No classroom cohorts are linked to this teacher yet.</div>
                ) : (
                  cohorts.map((cohort) => (
                    <button
                      key={cohort.cohortId}
                      className={`block w-full rounded-2xl border p-3 text-left transition-colors ${selectedCohortId === cohort.cohortId ? 'border-teal-700 bg-teal-50/80' : 'border-slate-200/80 bg-white/70 hover:bg-white/95'}`}
                      onClick={() => openCohort(cohort.cohortId)}
                    >
                      <div className="font-medium">Cohort {cohort.cohortId}</div>
                      <div className="teacher-muted mt-1 text-sm">
                        {cohort.courses.length} course{cohort.courses.length === 1 ? '' : 's'} · {cohort.courses.map((course) => course.name).join(', ')}
                      </div>
                    </button>
                  ))
                )}
              </div>
            </section>

            <section className="teacher-panel rounded-[1.75rem] p-5">
              <div className="flex items-center justify-between gap-3">
                <div>
                  <h2 className="text-lg font-semibold">Roster</h2>
                  <p className="teacher-muted mt-1 text-sm">
                    {selectedCohortId ? `Cohort ${selectedCohortId}` : 'Select a classroom to load its students.'}
                  </p>
                </div>
                <button
                  className="teacher-button-secondary rounded-xl px-3 py-2 text-sm transition hover:bg-white/90 disabled:opacity-50"
                  disabled={!selectedCohortId || joinCodeBusy}
                  onClick={generateJoinCode}
                >
                  {joinCodeBusy ? 'Generating…' : 'Create join code'}
                </button>
              </div>

              {selectedCourses.length > 0 ? (
                <div className="mt-3 flex flex-wrap gap-2">
                  {selectedCourses.map((course) => (
                    <span key={course.id} className="teacher-chip rounded-full px-3 py-1 text-xs font-medium">
                      {course.name} · {course.subject}
                    </span>
                  ))}
                </div>
              ) : null}

              {joinCode ? (
                <div className="mt-4 rounded-lg border border-emerald-200 bg-emerald-50 p-4">
                  <div className="text-xs uppercase tracking-wide text-emerald-700">Live join code</div>
                  <div className="mt-2 text-3xl font-semibold tracking-[0.35em] text-emerald-950">{joinCode.code}</div>
                  <div className="mt-2 text-sm text-emerald-800">
                    Share this with students for classroom self-join. {joinCode.expiresAt ? `Expires ${new Date(joinCode.expiresAt).toLocaleString()}.` : 'No expiry set.'}
                  </div>
                </div>
              ) : null}

              <div className="mt-4 overflow-hidden rounded-2xl border border-slate-200/80">
                <table className="teacher-grid-table w-full text-sm">
                  <thead className="text-left text-gray-600">
                    <tr>
                      <th className="px-3 py-2">Student</th>
                      <th className="px-3 py-2">Role</th>
                      <th className="px-3 py-2">Email</th>
                    </tr>
                  </thead>
                  <tbody>
                    {students.map((student) => (
                      <tr key={student.studentId} className="border-t border-slate-200/70">
                        <td className="px-3 py-2 font-medium">{student.name}</td>
                        <td className="px-3 py-2">
                          <span className="rounded-full bg-sky-100 px-2 py-1 text-xs font-medium text-sky-800">Student</span>
                        </td>
                        <td className="teacher-muted px-3 py-2">{student.email ?? 'No email'}</td>
                      </tr>
                    ))}
                    {selectedCohortId && students.length === 0 ? (
                      <tr>
                        <td colSpan={3} className="px-3 py-6 text-center text-sm text-gray-500">
                          No students are enrolled in this classroom yet.
                        </td>
                      </tr>
                    ) : null}
                    {!selectedCohortId ? (
                      <tr>
                        <td colSpan={3} className="px-3 py-6 text-center text-sm text-gray-500">
                          Select a classroom to load the roster.
                        </td>
                      </tr>
                    ) : null}
                  </tbody>
                </table>
              </div>
            </section>
          </div>
        </div>
      </AdminShell>
    </RequireAuth>
  );
}
