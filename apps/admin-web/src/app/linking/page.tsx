'use client';

import { useState } from 'react';
import { apiFetch } from '@/lib/api';
import AdminShell from '@/components/AdminShell';
import RequireAuth from '@/components/RequireAuth';

export default function LinkingPage() {
  const [parentEmail, setParentEmail] = useState('');
  const [studentEmail, setStudentEmail] = useState('');
  const [err, setErr] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);

  async function link() {
    setErr(null);
    setOk(null);
    try {
      await apiFetch('/admin/link-parent-student', {
        method: 'POST',
        body: JSON.stringify({ parentEmail, studentEmail }),
      });
      setOk('Linked');
    } catch (e: any) {
      setErr(e?.message ?? 'Link failed');
    }
  }

  return (
    <RequireAuth>
      <AdminShell>
        <div className="space-y-4 p-6">
          <h1 className="text-2xl font-semibold">Linking</h1>

          {err && <div className="rounded border border-red-200 bg-red-50 p-3 text-sm text-red-700">{err}</div>}
          {ok && <div className="rounded border border-green-200 bg-green-50 p-3 text-sm text-green-700">{ok}</div>}

          <div className="rounded border p-4">
            <div className="text-sm font-medium">Link parent ↔ student</div>
            <div className="mt-3 grid gap-3 md:grid-cols-2">
              <div>
                <label className="text-xs text-gray-600">Parent email</label>
                <input className="mt-1 w-full rounded border px-3 py-2 text-sm" value={parentEmail} onChange={(e) => setParentEmail(e.target.value)} placeholder="parent1@classmate.app" />
              </div>
              <div>
                <label className="text-xs text-gray-600">Student email</label>
                <input className="mt-1 w-full rounded border px-3 py-2 text-sm" value={studentEmail} onChange={(e) => setStudentEmail(e.target.value)} placeholder="student1@classmate.app" />
              </div>
            </div>
            <div className="mt-3">
              <button className="rounded bg-black px-3 py-2 text-sm text-white hover:opacity-90 disabled:opacity-50" onClick={link} disabled={!parentEmail.trim() || !studentEmail.trim()}>
                Link
              </button>
            </div>
            <div className="mt-2 text-xs text-gray-500">If this endpoint doesn’t exist yet, we add it in API next.</div>
          </div>
        </div>
      </AdminShell>
    </RequireAuth>
  );
}
