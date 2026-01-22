'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { parentGrades } from '@/lib/api';
import { useParentAuth } from '@/lib/useParentAuth';

export default function ChildGradesPage() {
  const token = useParentAuth();
  const { studentId } = useParams<{ studentId: string }>();

  const [byCourse, setByCourse] = useState<Record<string, any[]>>({});
  const [err, setErr] = useState<string | null>(null);

  useEffect(() => {
    if (!token) return;

    (async () => {
      try {
        const res = await parentGrades(studentId);
        const grades = res?.grades ?? res ?? [];

        const grouped: Record<string, any[]> = {};
        for (const g of grades) {
          const key = g.courseName ?? 'Other';
          grouped[key] = grouped[key] || [];
          grouped[key].push(g);
        }

        // newest first if date exists
        Object.values(grouped).forEach(list =>
          list.sort((a, b) =>
            String(b.at ?? '').localeCompare(String(a.at ?? ''))
          )
        );

        setByCourse(grouped);
      } catch (e: any) {
        setErr(e?.message ?? 'Failed to load grades');
      }
    })();
  }, [studentId, token]);

  return (
    <main className="min-h-screen p-6 max-w-3xl mx-auto">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold">Grades</h1>
        <Link className="rounded-md border px-3 py-2 text-sm" href={`/child/${studentId}`}>
          Back
        </Link>
      </div>

      {err && <div className="mt-4 text-sm text-red-600">{err}</div>}

      <div className="mt-6 space-y-6">
        {Object.entries(byCourse).map(([course, list]) => (
          <section key={course}>
            <h2 className="font-medium">{course}</h2>
            <div className="mt-2 space-y-2">
              {list.map((g, i) => (
                <div key={i} className="rounded-lg border p-3">
                  <div className="font-medium">
                    {g.assessmentName ?? 'Assessment'}
                  </div>
                  <div className="text-sm opacity-70">
                    {g.score}/{g.maxScore}
                    {g.maxScore ? (
                      <> · {Math.round((g.score / g.maxScore) * 100)}%</>
                    ) : null}
                  </div>
                </div>
              ))}
            </div>
          </section>
        ))}

        {Object.keys(byCourse).length === 0 && !err && (
          <div className="opacity-70">No grades published yet.</div>
        )}
      </div>
    </main>
  );
}
