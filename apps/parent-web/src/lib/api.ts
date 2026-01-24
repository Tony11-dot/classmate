const TOKEN_KEY = 'parent_token';

export function getToken() {
  if (typeof window === 'undefined') return null;
  return window.localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string) {
  if (typeof window === 'undefined') return;
  window.localStorage.setItem(TOKEN_KEY, token);
  window.dispatchEvent(new Event('classmate_token_change'));
}

export function clearToken() {
  if (typeof window === 'undefined') return;
  window.localStorage.removeItem(TOKEN_KEY);
  window.dispatchEvent(new Event('classmate_token_change'));
}
const API_BASE = 'http://localhost:3000';

type ApiOpts = {
  method?: string;
  body?: any;
};

async function api<T = any>(path: string, opts: ApiOpts = {}): Promise<T> {
  const token = getToken();
  if (!token) throw new Error('Missing parent token. Go to /login and sign in.');

  const res = await fetch(`${API_BASE}${path}`, {
    method: opts.method ?? 'GET',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: opts.body === undefined ? undefined : JSON.stringify(opts.body),
  });

  const text = await res.text();
  let json: any = null;
  try { json = text ? JSON.parse(text) : null; } catch { json = { ok: false, message: text }; }

  if (!res.ok) {
    const msg = json?.message || json?.error || `HTTP ${res.status}`;
    throw new Error(msg);
  }
  return json as T;
}

// ---- Parent APIs ----

export function parentLookup() {
  return api<{ ok: true; students: { id: string; name: string }[]; courses: { id: string; name: string; subject: string; cohortId: string }[] }>(
    '/api/parent/lookup',
  );
}

export function parentUnreadCount(opts?: { studentId?: string; since?: string }) {
  const qs = new URLSearchParams();
  if (opts?.studentId) qs.set('studentId', opts.studentId);
  if (opts?.since) qs.set('since', opts.since);
  const q = qs.toString();
  return api<{ ok: true; unread: number; since: string | null; breakdown: Record<string, number> }>(
    `/api/parent/notifications/unread-count${q ? `?${q}` : ''}`,
  );
}


export function parentRecentNotifications(take = 5) {
  return parentNotifications({ take });
}

export function parentNotifications(opts?: { studentId?: string; take?: number }) {
  const qs = new URLSearchParams();
  if (opts?.studentId) qs.set('studentId', opts.studentId);
  if (typeof opts?.take === 'number') qs.set('take', String(opts.take));
  const q = qs.toString();
  return api<{ ok: true; notifications: any[] }>(
    `/api/parent/notifications${q ? `?${q}` : ''}`,
  );
}

export function parentMarkSeen(body?: { ids?: string[] }) {
  return api<{ ok: true; lastSeenAt: string }>(
    '/api/parent/notifications/mark-seen',
    { method: 'POST', body: body ?? {} },
  );
}

// existing endpoints you already had (kept for other pages)
export function parentChildren() {
  return api('/api/parent/children');
}
export function parentOverview(studentId: string) {
  return api(`/api/parent/overview?studentId=${encodeURIComponent(studentId)}`);
}
export function parentGrades(studentId: string) {
  return api(`/api/parent/grades?studentId=${encodeURIComponent(studentId)}`);
}
export function parentWeek(studentId: string) {
  return api(`/api/parent/overview/week?studentId=${encodeURIComponent(studentId)}`);
}

// Back-compat alias (dashboard expects this name)
export function parentOverviewWeek(studentId: string) {
  return parentWeek(studentId);
}
export function parentAlertsSettings(studentId: string) {
  return api(`/api/parent/alerts/settings?studentId=${encodeURIComponent(studentId)}`);
}
export function parentSaveAlertsSettings(body: any) {
  return api('/api/parent/alerts/settings', { method: 'POST', body });
}
