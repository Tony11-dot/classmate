'use client';

import { useEffect, useMemo, useState } from 'react';
import { apiFetch, fetchAssessmentGrades, fetchCohortStudents, type CohortStudent } from '@/lib/api';
import { RequireAuth } from '@/components/RequireAuth';
import { AdminShell } from '@/components/AdminShell';

type Course = { id: string; name: string; subject: string; cohortId: string | null };
type Assessment = {
  id: string;
  courseId: string;
  title: string;
  date: string; // ISO
  maxGrade?: number;
  createdBy?: string;
  course?: { id: string; name: string; subject: string; cohortId?: string | null };
};


function errMsg(e: unknown, fallback: string) {
  return e instanceof Error ? e.message : fallback;
}

type ListAssessmentsResp =
  | { ok: true; courses: Course[]; assessments: Assessment[] }
  | { ok: true; course: Course; assessments: Assessment[] };

export default function GradesPage() {
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const [courses, setCourses] = useState<Course[]>([]);
  const [assessments, setAssessments] = useState<Assessment[]>([]);

  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [students, setStudents] = useState<CohortStudent[]>([]);
  const [gradesDraft, setGradesDraft] = useState<Record<string, number | ''>>({});
  const [savingGrades, setSavingGrades] = useState(false);
  const [saveError, setSaveError] = useState('');
  const [gradeErrors, setGradeErrors] = useState<Record<string, string>>({});


  // create form
  const [courseId, setCourseId] = useState('');
  const [title, setTitle] = useState('');
  const [date, setDate] = useState(''); // YYYY-MM-DD optional
  const [maxGrade, setMaxGrade] = useState(''); // optional number

  async function refresh() {
    setErr(null);
    setLoading(true);
    try {
      const res = await apiFetch<ListAssessmentsResp>('/teacher/grades/assessments');
      if ('courses' in res) {
        setCourses(res.courses);
        setAssessments(res.assessments);
        if (!courseId && res.courses.length) setCourseId(res.courses[0].id);
      } else {
        // courseId filtered response shape (not used now, but safe)
        setCourses([res.course]);
        setAssessments(res.assessments);
        if (!courseId) setCourseId(res.course.id);
      }
    } catch (e: unknown) {
      setErr(errMsg(e, 'Failed to load grades'));
    } finally {
      setLoading(false);
    }
  }

  async function createAssessment() {
    setErr(null);
    setLoading(true);
    try {
      const body: { courseId: string; title: string; date?: string; maxGrade?: number } = { courseId, title };
      const mg = maxGrade.trim();
      if (mg) {
        const n = Number(mg);
        if (!Number.isFinite(n) || n <= 0) throw new Error('Max grade must be a positive number');
        body.maxGrade = Math.round(n);
      }
      if (date) body.date = date; // service expects YYYY-MM-DD
      const res = await apiFetch<{ ok: true; assessment: Assessment }>(
        '/teacher/grades/assessment',
        { method: 'POST', body: JSON.stringify(body) },
      );
      // optimistic insert
      setAssessments((a) => [res.assessment, ...a]);
      setTitle('');
      setDate('');
      setMaxGrade('');
    } catch (e: unknown) {
      setErr(errMsg(e, 'Create assessment failed'));
    } finally {
      setLoading(false);
    }
  }

  async function openAssessment(a: Assessment) {
    setErr(null);
    setSelectedId((prev) => {
      if (prev === a.id) {
        setTimeout(() => setSelectedId(a.id), 0);
        return null;
      }
      return a.id;
    });
setSaveError('');
    setGradeErrors({});
    setStudents([]);
    setGradesDraft({});
    try {
      const cohortId = a.course?.cohortId ?? courses.find((c) => c.id === a.courseId)?.cohortId ?? null;
      if (!cohortId) {
        setErr('Course cohortId missing (cannot load students)');
        return;
      }
      const res = await fetchCohortStudents(cohortId);
      // prefill any existing grades for this assessment
      const g = await fetchAssessmentGrades(a.id);
      const gradeMap = new Map(g.grades.map((r) => [r.studentId, r.grade]));      setGradesDraft(() => {
        const d: Record<string, number | ''> = {};
        for (const st of res.students) d[st.studentId] = gradeMap.get(st.studentId) ?? '';
        return d;
      });
      setStudents(res.students);
    } catch (e: unknown) {
      setErr(errMsg(e, 'Failed to load cohort students'));
    }
  }

  async function saveGrades() {
    if (!selectedId) return;
    setErr(null);
    setSavingGrades(true);
    try {
      const grades = students
        .map((st) => ({ studentId: st.studentId, grade: gradesDraft[st.studentId] }))
        .filter((g) => g.grade !== '' && g.grade !== undefined)
        .map((g) => ({ studentId: g.studentId, grade: Number(g.grade) }));
      if (grades.length === 0) {
        setErr('Enter at least one grade');
        return;
      }
      await apiFetch('/teacher/grades/bulk', {
        method: 'POST',
        body: JSON.stringify({ assessmentId: selectedId, grades }),
      });
    } catch (e: unknown) {
      setErr(errMsg(e, 'Save grades failed'));
    } finally {
      setSavingGrades(false);
    }
  }

  async function deleteAssessment(id: string) {
    if (!confirm('Delete this assessment? (grades will be deleted too)')) return;
    setErr(null);
    setLoading(true);
    try {
      await apiFetch(`/teacher/grades/assessment/${id}`, { method: 'DELETE' });
      setAssessments((a) => a.filter((x) => x.id !== id));
    } catch (e: unknown) {
      setErr(errMsg(e, 'Delete failed'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    refresh();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const byCourse = useMemo(() => {
    const m = new Map<string, Assessment[]>();
    for (const a of assessments) {
      const cid = a.courseId;
      if (!m.has(cid)) m.set(cid, []);
      m.get(cid)!.push(a);
    }
    // sort per course by date desc then id desc (API already does, but keep stable)
    for (const [k, arr] of m.entries()) {
      arr.sort((x, y) => (y.date + y.id).localeCompare(x.date + x.id));
      m.set(k, arr);
    }
    return m;
  }, [assessments]);
  const selected = assessments.find((a) => a.id === selectedId);
  const selectedMax = selected?.maxGrade ?? null;


  return (
    <RequireAuth>
      <AdminShell>
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h1 className="text-xl font-semibold">Grades</h1>
            <button
              className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
              onClick={refresh}
              disabled={loading}
            >
              {loading ? 'Loading…' : 'Refresh'}
            </button>
          </div>

          <div className="rounded border p-4">
            <div className="text-sm text-gray-700">Create assessment</div>
            <div className="mt-3 grid gap-3 md:grid-cols-4">
              <div>
                <label className="text-xs text-gray-600">Course</label>
                <select
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  value={courseId}
                  onChange={(e) => setCourseId(e.target.value)}
                >
                  {courses.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="text-xs text-gray-600">Title</label>
                <input
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="e.g. Quiz 3"
                />
              </div>
              <div>
                <label className="text-xs text-gray-600">Date (optional)</label>
                <input
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  value={date}
                  onChange={(e) => setDate(e.target.value)}
                  placeholder="YYYY-MM-DD"
                />
              </div>
              <div>
                <label className="text-xs text-gray-600">Max grade (optional)</label>
                <input
                  className="mt-1 w-full rounded border px-3 py-2 text-sm"
                  value={maxGrade}
                  onChange={(e) => setMaxGrade(e.target.value)}
                  placeholder="e.g. 100 or 120"
                  inputMode="numeric"
                />
              </div>
            </div>

            <div className="mt-3">
              <button
                className="rounded bg-black px-3 py-2 text-sm text-white hover:opacity-90 disabled:opacity-50"
                disabled={loading || !courseId || !title.trim()}
                onClick={createAssessment}
              >
                Create
              </button>
            </div>
          </div>

          {selectedId && (
            <div className="rounded border p-4" data-testid="grade-entry">
              <div className="flex items-center justify-between">
                <div className="text-sm font-medium">Grade entry</div>
                <button
                  className="rounded bg-black px-3 py-2 text-sm text-white hover:opacity-90 disabled:opacity-50"
                  disabled={savingGrades || students.length === 0 || Object.keys(gradeErrors).length > 0}
                  onClick={saveGrades}
                >
                  {savingGrades ? 'Saving…' : 'Save grades'}
                </button>
              </div>

              <div className="mt-3 text-xs text-gray-600">
                Selected assessment: {selected?.title ?? selectedId}{selected?.maxGrade != null ? (' (Max ' + selected.maxGrade + ')') : ''}
              </div>

              {students.length === 0 ? (
                <div className="mt-3 text-sm text-gray-500">No students loaded.</div>
              ) : (
                <div className="mt-3 overflow-hidden rounded border">
                  <table className="w-full text-sm" data-testid="grades-entry-table">
                    <thead className="bg-gray-50 text-left text-gray-600">
                      <tr>
                        <th className="px-3 py-2">Student</th>
                        <th className="px-3 py-2">Grade</th>
                      </tr>
                    </thead>
                    <tbody>
                      {students.map((st) => (
                        <tr key={st.studentId} className="border-t">
                          <td className="px-3 py-2">{st.name}</td>
                          
                          <td className="py-2 pr-4 text-sm text-gray-900">{st.name}</td>
                          <td className="px-3 py-2">
                            <input
                              className="w-28 rounded border px-2 py-1"
                              type="number" min={0} max={selectedMax ?? undefined}
                              data-testid={`grade-${st.studentId}`}
                             
                             
                              value={gradesDraft[st.studentId] ?? ''}
                              onChange={(e) => {
      setSaveError('');
      const raw = e.target.value;
      const n = raw === '' ? null : Number(raw);

      setGrades((prev) => ({ ...prev, [st.studentId]: raw }));

      setGradeErrors((prev) => {
        const next = { ...prev };

        if (raw === '') {
          delete next[st.studentId];
          return next;
        }
        if (!Number.isFinite(n) || n == null) {
          next[st.studentId] = 'Invalid number';
          return next;
        }
        if (n < 0) {
          next[st.studentId] = 'Cannot be negative';
          return next;
        }
        if (selectedMax != null && n > selectedMax) {
          next[st.studentId] = `Max is ${selectedMax}`;
          return next;
        }
        delete next[st.studentId];
        return next;
      });
    }}
                            />
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}

          {err && (
            <div className="rounded border border-red-200 bg-red-50 p-3 text-sm text-red-700">
              {err}
            </div>
          )}

          <div className="space-y-4">
            {courses.map((c) => {
              const list = byCourse.get(c.id) ?? [];
              return (
                <div key={c.id} className="rounded border">
                  <div className="flex items-center justify-between border-b bg-gray-50 px-4 py-3">
                    <div className="text-sm font-medium">{c.name}</div>
                    <div className="text-xs text-gray-600">{c.subject}</div>
                  </div>

                  <div className="p-4">
                    {list.length === 0 ? (
                      <div className="text-sm text-gray-500">No assessments yet.</div>
                    ) : (
                      <table className="w-full text-sm">
                        <thead className="text-left text-gray-600">
                          <tr>
                            <th className="py-2">Title</th>
                            <th className="py-2">Date</th>
                            <th className="py-2 text-right">Actions</th>
                          </tr>
                        </thead>
                        <tbody>
                          {list.map((a) => (
                            <tr key={a.id} className="border-t">
                              <td className="py-2">{a.title}</td>
                              <td className="py-2">{new Date(a.date).toISOString().slice(0, 10)}</td>
                <td className="px-3 py-2 text-sm">{a.maxGrade ?? '-'}</td>
                              <td className="py-2 text-right">
                          <button
                            className="mr-2 rounded border px-2 py-1 text-xs hover:bg-gray-50"
                            onClick={() => openAssessment(a)}
                          >
                            Open
                          </button>
                          <button
                            className="rounded border px-2 py-1 text-xs hover:bg-gray-50"
                            onClick={() => deleteAssessment(a.id)}
                          >
                            Delete
                          </button>
                          </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </AdminShell>
    </RequireAuth>
  );
}
