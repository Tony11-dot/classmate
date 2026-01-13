const API_BASE =
  process.env.NEXT_PUBLIC_API_BASE?.replace(/\/$/, '') ?? 'http://localhost:3000';

const TOKEN_KEY = 'classmate_token';

export function setToken(token: string) {
  if (typeof window === 'undefined') return;
  window.localStorage.setItem(TOKEN_KEY, token);
}

export function getToken(): string | null {
  if (typeof window === 'undefined') return null;
  return window.localStorage.getItem(TOKEN_KEY);
}

export function clearToken() {
  if (typeof window === 'undefined') return;
  window.localStorage.removeItem(TOKEN_KEY);
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

function extractMessage(data: unknown, fallback: string) {
  if (!isObject(data)) return fallback;
  const msg = data.message;
  if (typeof msg === 'string') return msg;
  if (Array.isArray(msg)) return msg.map(String).join(', ');
  return fallback;
}

export async function apiFetch<T>(
  path: string,
  init: RequestInit = {},
): Promise<T> {
  const token = getToken();

  const headers = new Headers(init.headers);
  if (!headers.has('Content-Type')) headers.set('Content-Type', 'application/json');
  if (token) headers.set('Authorization', `Bearer ${token}`);

  const res = await fetch(`${API_BASE}${path}`, { ...init, headers });

  const text = await res.text();
  const data: unknown = text
    ? (() => {
        try {
          return JSON.parse(text) as unknown;
        } catch {
          return text;
        }
      })()
    : null;

  if (!res.ok) {
    throw new Error(extractMessage(data, `Request failed (${res.status})`));
  }

  return data as T;
}


export type CohortStudent = { studentId: string; name: string };

export async function fetchCohortStudents(cohortId: string) {
  return apiFetch<{ ok: true; cohortId: string; students: CohortStudent[] }>(
    `/teacher/cohort/${cohortId}/students`,
  );
}

