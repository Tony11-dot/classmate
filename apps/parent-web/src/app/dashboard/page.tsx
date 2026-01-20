'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { parentChildren, getToken, clearToken } from "@/lib/api";

export default function DashboardPage() {
  const [kids, setKids] = useState<any[]>([]);
  const [err, setErr] = useState<string | null>(null);


  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Parent Dashboard</h1>
        <Link className="rounded-md border px-3 py-2 text-sm" href="/login">Login</Link>
      </div>

      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}

      <section className="mt-6">
        <h2 className="font-semibold">Children</h2>
        <div className="mt-2 space-y-2">
          {kids.map((k) => (
            <Link
        <button className="rounded-md border px-3 py-2 text-sm" onClick={() => { clearToken(); window.location.href = "/login"; }}>Logout</button>

              href={`/child/${k.studentId}`}
              className="block rounded-lg border p-3 hover:bg-black/5"
            >
              <div className="font-medium">{k.name}</div>
              <div className="text-sm opacity-70">
                {k.cohort?.name} · Grade {k.cohort?.grade} · {k.status}
              </div>
            </Link>
          ))}
          {kids.length === 0 && <div className="opacity-70">No children linked.</div>}
        </div>
      </section>
    </main>
  );
}
