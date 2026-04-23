'use client';

import Link from 'next/link';
import { useParams } from 'next/navigation';

export default function AlertsSettingsPage() {
  const params = useParams();
  const studentId = String(params.studentId);

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Alert Settings</h1>
        <Link className="rounded-md border px-3 py-2 text-sm" href={`/child/${studentId}`}>
          Back
        </Link>
      </div>

      <div className="mt-6 rounded-lg border p-4 text-sm opacity-80">
        Parent alert thresholds are not available in this school backend yet. This page stays visible so navigation remains stable, but there are no live alert settings to edit right now.
      </div>
    </main>
  );
}
