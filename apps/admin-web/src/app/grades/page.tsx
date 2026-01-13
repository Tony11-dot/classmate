'use client';

import { useEffect, useMemo, useState } from 'react';
import { AdminShell } from '../../components/AdminShell';
import { RequireAuth } from '../../components/RequireAuth';
import { apiFetch } from '../../lib/api';
import { toast } from '../../components/Toast';

type Assessment = {
  id: string;
  name: string;
  date: string; // YYYY-MM-DD
  cohort: { id: string; name: string; grade: number };
  course: { id: string; name: string };
};

type AssessmentsResponse = Assessment[];

export default function GradesPage() {
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const [assessments, setAssessments] = useState<Assessment[]>([]);
  const [selectedId, setSelectedId] = useState<string>('');

  // simple create form (MVP)
  const [name, setName] = useState('Quiz 1');
  const [date, setDate] = useState('');
  const [cohortId, setCohortId] = useState('');
  const [courseId, setCourseId] = useState('');

  async function loadAssessments() {
    setErr(null);
    setLoading(true);
    try {
      const res = await apiFetch<AssessmentsResponse>('/teacher/grades/assessments');
      setAssessments(res);
      if (!selectedId && res[0]?.id) setSelectedId(res[0].id);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Failed to load assessments';
      setErr(msg);
      toast(msg, 'error');
    } finally {
      setLoading(false);
    }
  }

  async function createAssessment() {
    setErr(null);
    setLoading(true);
    try {
      // NOTE: adjust payload keys if your API expects different ones
      const res = await apiFetch<Assessment>('/teacher/grades/assessment', {
        method: 'POST',
        body: JSON.stringify({ name, date, cohortId, courseId }),
      });
      toast('Assessment created', 'success');
      await loadAssessments();
      setSelectedId(res.id);
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Create failed';
      setErr(msg);
      toast(msg, 'error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    // default date to today (client-side only)
    const d = new Date();
    const iso = d.toISOString().slice(0, 10);
    setDate((x) => x || iso);
    loadAssessments();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const selected = useMemo(
    () => assessments.find((a) => a.id === selectedId) ?? null,
    [assessments, selectedId],
  );

  return (
    <RequireAuth>
      <AdminShell>
        <div className="p-6">
          <div className="text-xl font-semibold">Grades</div>
          <div className="mt-1 text-sm text-gray-600">
            MVP: create/select an assessment. Next: enter grades + bulk save.
          </div>

          <div className="mt-4 flex flex-wrap items-center gap-2">
            <button
              className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
              disabled={loading}
              onClick={loadAssessments}
              data-testid="grades-refresh"
            >
              {loading ? 'Loading…' : 'Refresh'}
            </button>
          </div>

          {err && (
            <div className="mt-4 rounded border border-red-200 bg-red-50 p-3 text-sm text-red-700">
              {err}
            </div>
          )}

          <div className="mt-6 grid gap-4 md:grid-cols-2">
            <div className="rounded border p-4">
              <div className="font-medium">Create assessment</div>

              <div className="mt-3 grid gap-3">
                <div>
                  <label className="text-sm text-gray-700">Name</label>
                  <input
                    className="mt-1 w-full rounded border px-3 py-2"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="e.g. Quiz 1"
                  />
                </div>

                <div>
                  <label className="text-sm text-gray-700">Date</label>
                  <input
                    className="mt-1 w-full rounded border px-3 py-2"
                    value={date}
                    onChange={(e) => setDate(e.target.value)}
                    placeholder="YYYY-MM-DD"
                  />
                </div>

                <div>
                  <label className="text-sm text-gray-700">Cohort ID</label>
                  <input
                    className="mt-1 w-full rounded border px-3 py-2"
                    value={cohortId}
                    onChange={(e) => setCohortId(e.target.value)}
                    placeholder="paste cohortId"
                  />
                </div>

                <div>
                  <label className="text-sm text-gray-700">Course ID</label>
                  <input
                    className="mt-1 w-full rounded border px-3 py-2"
                    value={courseId}
                    onChange={(e) => setCourseId(e.target.value)}
                    placeholder="paste courseId"
                  />
                </div>

                <button
                  className="rounded bg-black px-3 py-2 text-sm text-white hover:opacity-90 disabled:opacity-50"
                  disabled={loading || !name || !date || !cohortId || !courseId}
                  onClick={createAssessment}
                  data-testid="grades-create"
                >
                  Create
                </button>

                <div className="text-xs text-gray-500">
                  Tip: you can get cohortId/courseId from the Attendance “Today sessions” cards (we’ll wire auto-pick next).
                </div>
              </div>
            </div>

            <div className="rounded border p-4">
              <div className="font-medium">Assessments</div>

              <div className="mt-3">
                <select
                  className="w-full rounded border px-3 py-2"
                  value={selectedId}
                  onChange={(e) => setSelectedId(e.target.value)}
                  data-testid="grades-assessment-select"
                >
                  <option value="">Select…</option>
                  {assessments.map((a) => (
                    <option key={a.id} value={a.id}>
                      {a.name} — {a.date} — {a.cohort.name} — {a.course.name}
                    </option>
                  ))}
                </select>
              </div>

              {selected && (
                <div className="mt-4 rounded border p-3 text-sm">
                  <div className="text-gray-600">
                    {selected.cohort.name} (grade {selected.cohort.grade}) — {selected.date}
                  </div>
                  <div className="mt-1 font-medium">{selected.course.name}</div>
                  <div className="mt-2 text-xs text-gray-500">
                    Next step: load roster + input grades + bulk save.
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </AdminShell>
    </RequireAuth>
  );
}
