'use client';

import { useEffect, useMemo, useState } from 'react';
import { RequireAuth } from '../../components/RequireAuth';
import { AdminShell } from '../../components/AdminShell';
import { apiFetch } from '../../lib/api';
import { toast } from '../../components/Toast';

type AttendanceStatus = 'PRESENT' | 'ABSENT' | 'LATE' | 'EXCUSED';

type SessionStudent = {
  studentId: string;
  name: string;
  status: AttendanceStatus;
  note?: string | null;
};

type AttendanceSessionResponse = {
  cohort: { id: string; name: string; grade: number };
  date: string; // YYYY-MM-DD
  period: number;
  course: { id: string; name: string; subject: string };
  students: SessionStudent[];
};

type DraftRow = { status: AttendanceStatus; note: string };

type BulkRequest = {
  cohortId: string;
  date: string;
  period: number;
  records: Array<{ studentId: string; status: AttendanceStatus; note?: string }>;
};

export default function AttendancePage() {
  const [cohortId, setCohortId] = useState('84dd70e6-7739-49a9-93bf-8f9afae41246');
  const [date, setDate] = useState('2026-01-08');
  const [period, setPeriod] = useState<number>(1);

  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const [data, setData] = useState<AttendanceSessionResponse | null>(null);
  const [draft, setDraft] = useState<Record<string, DraftRow>>({});
  const [showChangedOnly, setShowChangedOnly] = useState(false);

  const originalById = useMemo(() => {
    const m = new Map<string, SessionStudent>();
    for (const s of data?.students ?? []) m.set(s.studentId, s);
    return m;
  }, [data]);

  const dirtyIds = useMemo(() => {
    const ids: string[] = [];
    for (const [id, row] of Object.entries(draft)) {
      const orig = originalById.get(id);
      if (!orig) continue;
      const origNote = orig.note ?? '';
      if (row.status !== orig.status || row.note !== origNote) ids.push(id);
    }
    return ids;
  }, [draft, originalById]);

  const dirtyCount = dirtyIds.length;

  // Cmd+S / Ctrl+S to Save (feels pro)
  useEffect(() => {
    function onKeyDown(e: KeyboardEvent) {
      const isSave = (e.metaKey || e.ctrlKey) && e.key.toLowerCase() === 's';
      if (!isSave) return;
      e.preventDefault();
      if (dirtyCount > 0 && !saving) saveBulk();
    }
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [dirtyCount, saving]);


  function getRow(student: SessionStudent): DraftRow {
    const d = draft[student.studentId];
    if (d) return d;
    return { status: student.status, note: student.note ?? '' };
  }

  async function loadSession() {
    setErr(null);
    setLoading(true);
    try {
      const q = new URLSearchParams({
        cohortId,
        date,
        period: String(period),
      }).toString();

      const res = await apiFetch<AttendanceSessionResponse>(
        `/teacher/attendance/session?${q}`,
      );

      setData(res);
      setDraft({});
      toast('Session loaded', 'success');
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Failed to load';
      setErr(msg);
      toast(msg, 'error');
      setData(null);
      setDraft({});
    } finally {
      setLoading(false);
    }
  }

  function setAllStatus(status: AttendanceStatus) {
    if (!data) return;
    setDraft((prev) => {
      const next = { ...prev };
      for (const s of data.students) {
        const cur = getRow(s);
        next[s.studentId] = { ...cur, status };
      }
      return next;
    });
  }

  function clearAllNotes() {
    if (!data) return;
    setDraft((prev) => {
      const next = { ...prev };
      for (const s of data.students) {
        const cur = getRow(s);
        next[s.studentId] = { ...cur, note: '' };
      }
      return next;
    });
  }

  async function saveBulk() {
    if (!data) return;
    if (dirtyCount === 0) return;

    setErr(null);
    setSaving(true);
    try {
      const records = dirtyIds.map((studentId) => {
        const row = draft[studentId];
        return {
          studentId,
          status: row.status,
          note: row.note.trim() ? row.note : undefined,
        };
      });

      const body: BulkRequest = {
        cohortId,
        date,
        period,
        records,
      };

      await apiFetch<{ ok: true; written: number; skipped: number }>(
        '/teacher/attendance/bulk',
        {
          method: 'POST',
          body: JSON.stringify(body),
        },
      );

      // Re-fetch to ensure we show server truth
      await loadSession();
      toast('Attendance saved', 'success');
    } catch (e: unknown) {
      const msg = e instanceof Error ? e.message : 'Save failed';
      setErr(msg);
      toast(msg, 'error');
    } finally {
      setSaving(false);
    }
  }

  const visibleStudents = useMemo(() => {
    if (!data) return [];
    if (!showChangedOnly) return data.students;
    const set = new Set(dirtyIds);
    return data.students.filter((s) => set.has(s.studentId));
  }, [data, showChangedOnly, dirtyIds]);

  return (
    <RequireAuth>
      <AdminShell>
        {saving && (
          <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/10">
            <div className="rounded border bg-white px-4 py-3 text-sm shadow-sm">
              Saving…
            </div>
          </div>
        )}
        <div className="flex flex-wrap items-end justify-between gap-3">
          <div>
            <h1 className="text-2xl font-semibold">Attendance</h1>
            <p className="mt-1 text-sm text-gray-600">
              Load a session, edit inline, Save sends only changed rows.
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button
              className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
              disabled={!data || dirtyCount === 0 || saving}
              onClick={() => {
                if (!data) return;
                setDraft({});
              }}
              title="Throw away local edits"
            >
              Reset edits
            </button>

            <button
              className="rounded bg-black px-3 py-2 text-sm text-white hover:opacity-90 disabled:opacity-50"
              disabled={!data || dirtyCount === 0 || saving}
              onClick={saveBulk}
            >
              {saving ? 'Saving…' : `Save (${dirtyCount})`}
            </button>
          </div>
        </div>

        <div className="mt-6 grid gap-3 md:grid-cols-4">
          <div className="md:col-span-2">
            <label className="text-sm text-gray-700">Cohort ID</label>
            <input
              className="mt-1 w-full rounded border px-3 py-2"
              value={cohortId}
              onChange={(e) => setCohortId(e.target.value)}
              placeholder="cohort UUID"
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
            <label className="text-sm text-gray-700">Period</label>
            <input
              className="mt-1 w-full rounded border px-3 py-2"
              type="number"
              min={1}
              max={12}
              value={period}
              onChange={(e) => setPeriod(Number(e.target.value))}
            />
          </div>
        </div>

        <div className="mt-4 flex flex-wrap items-center gap-2">
          <button
            className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
            disabled={loading}
            onClick={loadSession}
          >
            {loading ? 'Loading…' : 'Load session'}
          </button>

          <div className="h-6 w-px bg-gray-200" />

          <button
            className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
            disabled={!data}
            onClick={() => setAllStatus('PRESENT')}
          >
            Set all PRESENT
          </button>
          <button
            className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
            disabled={!data}
            onClick={() => setAllStatus('ABSENT')}
          >
            Set all ABSENT
          </button>
          <button
            className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
            disabled={!data}
            onClick={() => setAllStatus('LATE')}
          >
            Set all LATE
          </button>
          <button
            className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
            disabled={!data}
            onClick={() => setAllStatus('EXCUSED')}
          >
            Set all EXCUSED
          </button>

          <button
            className="rounded border px-3 py-2 text-sm hover:bg-gray-50 disabled:opacity-50"
            disabled={!data}
            onClick={clearAllNotes}
          >
            Clear all notes
          </button>

          <label className="ml-auto flex items-center gap-2 text-sm text-gray-700">
            <input
              type="checkbox"
              checked={showChangedOnly}
              onChange={(e) => setShowChangedOnly(e.target.checked)}
              disabled={!data}
            />
            Show changed only
          </label>
        </div>

        {err && (
          <div className="mt-4 rounded border border-red-200 bg-red-50 p-3 text-sm text-red-700">
            {err}
          </div>
        )}

        {data && (
          <div className="mt-6">
            <div className="rounded border p-4">
              <div className="text-sm text-gray-600">
                {data.cohort.name} (grade {data.cohort.grade}) — {data.date} —
                period {data.period}
              </div>
              <div className="mt-1 font-medium">{data.course.name}</div>
            </div>

            <div className="mt-4 overflow-hidden rounded border">
              <table className="w-full text-sm">
                <thead className="bg-gray-50 text-left">
                  <tr>
                    <th className="px-3 py-2">Student</th>
                    <th className="px-3 py-2">Status</th>
                    <th className="px-3 py-2">Note</th>
                    <th className="px-3 py-2 text-right">Dirty</th>
                  </tr>
                </thead>
                <tbody>
                  {visibleStudents.map((s) => {
                    const cur = getRow(s);
                    const origNote = s.note ?? '';
                    const changed =
                      cur.status !== s.status || cur.note !== origNote;

                    return (
                      <tr key={s.studentId} className="border-t">
                        <td className="px-3 py-2">{s.name}</td>

                        <td className="px-3 py-2">
                          <select
                            className="rounded border px-2 py-1"
                            value={cur.status}
                            onChange={(e) => {
                              const v = e.target.value as AttendanceStatus;
                              setDraft((d) => ({
                                ...d,
                                [s.studentId]: { ...cur, status: v },
                              }));
                            }}
                          >
                            {(['PRESENT', 'ABSENT', 'LATE', 'EXCUSED'] as const).map(
                              (opt) => (
                                <option key={opt} value={opt}>
                                  {opt}
                                </option>
                              ),
                            )}
                          </select>
                        </td>

                        <td className="px-3 py-2">
                          <input
                            className="w-full rounded border px-2 py-1"
                            value={cur.note}
                            placeholder="optional note"
                            onChange={(e) => {
                              const v = e.target.value;
                              setDraft((d) => ({
                                ...d,
                                [s.studentId]: { ...cur, note: v },
                              }));
                            }}
                          />
                        </td>

                        <td className="px-3 py-2 text-right">
                          {changed ? (
                            <span className="rounded bg-yellow-100 px-2 py-1 text-xs text-yellow-900">
                              dirty
                            </span>
                          ) : (
                            <span className="text-xs text-gray-400">—</span>
                          )}
                        </td>
                      </tr>
                    );
                  })}

                  {visibleStudents.length === 0 && (
                    <tr>
                      <td className="px-3 py-6 text-center text-gray-500" colSpan={4}>
                        No rows to show.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>

            <div className="mt-2 text-xs text-gray-500">
              Tip: “Save” sends only changed rows. “Reset edits” discards local changes.
            </div>
          </div>
        )}
      </AdminShell>
    </RequireAuth>
  );
}
