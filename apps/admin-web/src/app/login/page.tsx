'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { login } from '../../lib/auth';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('teacher1@classmate.app');
  const [password, setPassword] = useState('dev');
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  return (
    <div className="min-h-screen p-6 lg:p-8">
      <div className="mx-auto grid min-h-[calc(100vh-3rem)] max-w-6xl gap-6 lg:grid-cols-[1.05fr_0.95fr]">
        <section className="teacher-panel teacher-login-hero flex flex-col justify-between rounded-[2.25rem] p-8 lg:p-10">
          <div>
            <div className="teacher-kicker">Classmate</div>
            <h1 className="mt-4 max-w-xl text-4xl font-semibold leading-tight text-slate-900 lg:text-5xl">
              Teacher operations built for the real school day.
            </h1>
            <p className="teacher-muted mt-4 max-w-2xl text-base leading-7">
              Move from the day schedule into attendance, classroom rosters, join codes, and grading without leaving the teacher workflow.
            </p>
          </div>

          <div className="grid gap-3 md:grid-cols-3">
            <div className="teacher-panel rounded-2xl p-4">
              <div className="teacher-kicker">Daily flow</div>
              <div className="mt-2 text-sm font-medium text-slate-900">Today schedule, session loading, and bulk attendance.</div>
            </div>
            <div className="teacher-panel rounded-2xl p-4">
              <div className="teacher-kicker">Classrooms</div>
              <div className="mt-2 text-sm font-medium text-slate-900">Roster visibility and live join codes for cohort entry.</div>
            </div>
            <div className="teacher-panel rounded-2xl p-4">
              <div className="teacher-kicker">Assessment</div>
              <div className="mt-2 text-sm font-medium text-slate-900">Assessment creation with live grade entry against real student rosters.</div>
            </div>
          </div>
        </section>

        <section className="teacher-panel teacher-panel-strong flex items-center rounded-[2.25rem] p-6 lg:p-8">
          <div className="w-full">
            <div className="teacher-kicker">Teacher sign in</div>
            <h2 className="mt-3 text-3xl font-semibold text-slate-900">Open your workspace</h2>
            <p className="teacher-muted mt-2 text-sm leading-6">
              Use an authorized teacher or admin account. The workspace is connected to the same live cohorts, schedules, and grades used by students.
            </p>

            <div className="mt-8 space-y-4">
              <div>
                <label className="text-sm font-medium text-slate-700">Email</label>
                <input
                  className="mt-2 w-full rounded-2xl border border-slate-200 bg-white/85 px-4 py-3 outline-none transition focus:border-teal-600"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  autoComplete="email"
                />
              </div>

              <div>
                <label className="text-sm font-medium text-slate-700">Password</label>
                <input
                  className="mt-2 w-full rounded-2xl border border-slate-200 bg-white/85 px-4 py-3 outline-none transition focus:border-teal-600"
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  autoComplete="current-password"
                />
              </div>

              {err && (
                <div className="rounded-2xl border border-red-200 bg-red-50 p-3 text-sm text-red-700">
                  {err}
                </div>
              )}

              <button
                className="teacher-button-primary w-full rounded-2xl px-4 py-3 text-sm font-medium transition hover:opacity-95 disabled:opacity-50"
                disabled={loading}
                onClick={async () => {
                  setErr(null);
                  setLoading(true);
                  try {
                    await login(email, password);
                    router.replace('/');
                  } catch (e) {
                    if (e instanceof Error) {
                      setErr(e.message);
                    } else {
                      setErr('Login failed');
                    }
                  } finally {
                    setLoading(false);
                  }
                }}
              >
                {loading ? 'Signing in…' : 'Sign in'}
              </button>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
