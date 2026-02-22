'use client';

import { useState } from 'react';
import { apiFetch } from '@/lib/api';
import AdminShell from '@/components/AdminShell';
import RequireAuth from '@/components/RequireAuth';

export default function DevToolsPage() {
  const [log, setLog] = useState<string>('');

  async function run(path: string) {
    setLog('');
    try {
      const res: any = await apiFetch(path, { method: 'POST' });
      setLog(JSON.stringify(res ?? { ok: true }, null, 2));
    } catch (e: any) {
      setLog(e?.message ?? 'Failed');
    }
  }

  return (
    <RequireAuth>
      <AdminShell>
        <div className="space-y-4 p-6">
          <h1 className="text-2xl font-semibold">Dev tools</h1>
          <div className="rounded border p-4">
            <div className="text-sm font-medium">Seed</div>
            <div className="mt-3 flex flex-wrap gap-2">
              <button className="rounded border px-3 py-2 text-sm hover:bg-gray-50" onClick={() => run('/test/seed/admin-web')}>
                POST /api/test/seed/admin-web
              </button>
              <button className="rounded border px-3 py-2 text-sm hover:bg-gray-50" onClick={() => run('/test/seed/clear-tutor-characters')}>
                POST /api/test/seed/clear-tutor-characters
              </button>
            </div>
            <pre className="mt-3 max-h-72 overflow-auto rounded bg-gray-50 p-3 text-xs">{log}</pre>
          </div>
        </div>
      </AdminShell>
    </RequireAuth>
  );
}
