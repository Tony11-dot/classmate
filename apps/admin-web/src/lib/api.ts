export const TOKEN_KEY = 'cm_admin_token';
export const TOKEN_EVT = 'classmate:token';

function baseUrl() {
  return (
    process.env.NEXT_PUBLIC_API_BASE_URL ||
    process.env.NEXT_PUBLIC_API_BASE ||
    'http://127.0.0.1:3002'
  );
}

export function emitTokenChanged() {
  if (typeof window === 'undefined') return;
  try { window.dispatchEvent(new Event(TOKEN_EVT)); } catch {}
}

export function setToken(token: string) {
  if (typeof window === 'undefined') return;
  window.localStorage.setItem(TOKEN_KEY, token);
  emitTokenChanged();
}

export function clearToken() {
  if (typeof window === 'undefined') return;
  window.localStorage.removeItem(TOKEN_KEY);
  emitTokenChanged();
}

export function getToken(): string | null {
  if (typeof window === 'undefined') return null;
  return window.localStorage.getItem(TOKEN_KEY);
}

export async function apiFetch<T>(path: string, init: RequestInit = {}): Promise<T> {

  const b = baseUrl().replace(/\/$/, '');
  const baseEndsWithApi = /\/api$/.test(b);

  let p = path;
  if (!p.startsWith('http')) {
    p = p.startsWith('/') ? p : '/' + p;
    // only prefix /api if baseUrl is NOT already .../api
    if (!baseEndsWithApi && !p.startsWith('/api/')) p = '/api' + p;
    // if baseUrl already ends with /api, avoid /api/api
    if (baseEndsWithApi && p.startsWith('/api/')) p = p.replace(/^\/api/, '');
  }

  const url = p.startsWith('http') ? p : `${b}${p}`;

  // keep your debug log
  console.log(`apiFetch -> ${url}`, init?.method ?? 'GET');

  const token = getToken();

  const headers = new Headers(init.headers || {});
  if (!headers.has('content-type') && init.body != null) {
    headers.set('content-type', 'application/json');
  }
  if (token && !headers.has('authorization')) {
    headers.set('authorization', `Bearer ${token}`);
  }

  const res = await fetch(url, { ...init, headers });

  if (!res.ok) {
    const text = await res.text().catch(() => '');
    throw new Error(`HTTP ${res.status} ${res.statusText}${text ? ` - ${text}` : ''}`);
  }

  // 204 / empty
  if (res.status === 204) return undefined as T;

  const ct = res.headers.get('content-type') || '';
  if (ct.includes('application/json')) return (await res.json()) as T;

  // fallback
  return (await res.text()) as unknown as T;
}

/* ---- API helpers used by /grades page ---- */

export type CohortStudent = {
  id: string;
  name: string;
  email?: string | null;
};

export type AssessmentGrade = {
  studentId: string;
  assessmentId: string;
  score: number | null;
};

export async function fetchCohortStudents(cohortId: string) {
  return apiFetch<CohortStudent[] | { ok?: boolean; students: CohortStudent[] }>(`/teacher/cohorts/${cohortId}/students`);
}

export async function fetchAssessmentGrades(assessmentId: string) {
  return apiFetch<AssessmentGrade[]>(`/teacher/assessments/${assessmentId}/grades`);
}


