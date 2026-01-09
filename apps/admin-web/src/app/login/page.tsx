'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { login } from '../../lib/auth';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('admin@classmate.app');
  const [password, setPassword] = useState('dev');
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
      <div className="w-full max-w-md rounded-lg border bg-white p-6">
        <h1 className="text-xl font-semibold">Sign in</h1>
        <p className="mt-1 text-sm text-gray-600">
          Use an admin/teacher account
        </p>

        <div className="mt-6 space-y-3">
          <div>
            <label className="text-sm text-gray-700">Email</label>
            <input
              className="mt-1 w-full rounded border px-3 py-2"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="email"
            />
          </div>

          <div>
            <label className="text-sm text-gray-700">Password</label>
            <input
              className="mt-1 w-full rounded border px-3 py-2"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              autoComplete="current-password"
            />
          </div>

          {err && (
            <div className="rounded border border-red-200 bg-red-50 p-3 text-sm text-red-700">
              {err}
            </div>
          )}

          <button
            className="w-full rounded bg-black px-3 py-2 text-white hover:opacity-90 disabled:opacity-50"
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
    </div>
  );
}
