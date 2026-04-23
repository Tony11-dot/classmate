'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';

const RAW_API_BASE =
  process.env.NEXT_PUBLIC_API_BASE_URL?.replace(/\/$/, '') ??
  process.env.NEXT_PUBLIC_API_BASE?.replace(/\/$/, '') ??
  'http://127.0.0.1:3001';
const SERVER_API_BASE = RAW_API_BASE.replace(/\/api\/?$/, '');

function apiBase() {
  return typeof window === 'undefined' ? SERVER_API_BASE : '/api';
}

export default function LoginPage() {
  const r = useRouter();
  const [email, setEmail] = useState('parent1@classmate.app');
  const [password, setPassword] = useState('dev');
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setErr(null);
    setLoading(true);
    try {
      const res = await fetch(`${apiBase()}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      const text = await res.text();
      if (!res.ok) throw new Error(`${res.status} ${res.statusText}: ${text}`);
      const json = JSON.parse(text);
      if (!json.token) throw new Error('Missing token');
      localStorage.setItem('parent_token', json.token);
      r.push('/dashboard');
    } catch (e: any) {
      setErr(e?.message ?? 'Login failed');
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="min-h-screen p-6 max-w-md mx-auto">
      <h1 className="text-xl font-semibold">Parent Login</h1>
      <form className="mt-6 space-y-3" onSubmit={onSubmit}>
        <div className="space-y-1">
          <div className="text-sm">Email</div>
          <input className="w-full rounded-md border px-3 py-2" value={email} onChange={(e) => setEmail(e.target.value)} />
        </div>
        <div className="space-y-1">
          <div className="text-sm">Password</div>
          <input className="w-full rounded-md border px-3 py-2" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </div>
        {err && <div className="text-sm text-red-600">{err}</div>}
        <button className="rounded-md border px-3 py-2 text-sm" disabled={loading}>
          {loading ? 'Signing in...' : 'Sign in'}
        </button>
      </form>
    </main>
  );
}
