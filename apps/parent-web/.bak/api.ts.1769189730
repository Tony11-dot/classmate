const API_BASE = "http://localhost:3000";


export async function parentUnreadCount() {
  return api('/api/parent/notifications/unread-count');
}

export async function parentChildren() {
  return api('/api/parent/children');
}

export async function parentOverview(studentId: string) {
  return api(`/api/parent/overview?studentId=${encodeURIComponent(studentId)}`);
}

export async function parentGrades(studentId: string) {
  return api(`/api/parent/grades?studentId=${encodeURIComponent(studentId)}`);
}

export async function parentOverviewWeek(studentId: string) {
  return api(`/api/parent/overview/week?studentId=${encodeURIComponent(studentId)}`);
}

export function getToken() {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem('parent_token');
}

export function setToken(token: string) {
  if (typeof window === 'undefined') return;
  localStorage.setItem('parent_token', token);
}

export function clearToken() {
  if (typeof window === 'undefined') return;
  localStorage.removeItem('parent_token');
}

async function api(path: string) {
  const token = getToken();
  if (!token) {
    throw new Error('Missing parent token. Go to /login and sign in.');
  }

  const res = await fetch(`${API_BASE}${path}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
    cache: 'no-store',
  });

  const text = await res.text();
  if (!res.ok) {
    throw new Error(`${res.status} ${res.statusText}: ${text}`);
  }
  return text ? JSON.parse(text) : null;
}


export async function getAlertSettings(studentId: string) {
  return api(`/api/parent/alerts/settings?studentId=${encodeURIComponent(studentId)}`);
}

export async function updateAlertSettings(input: {
  studentId: string;
  minGrade?: number;
  maxAbsences?: number;
  maxLates?: number;
}) {
  const token = getToken();
  if (!token) throw new Error('Missing parent token. Go to /login and sign in.');

  const res = await fetch(`${API_BASE}/api/parent/alerts/settings`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify(input),
    cache: 'no-store',
  });

  const text = await res.text();
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}: ${text}`);
  return text ? JSON.parse(text) : null;
}


export async function parentNotifications() {
  return api('/api/parent/notifications');
}


export async function parentMarkSeen(input: { notificationIds: string[] }) {
  const res = await fetch(`${API_BASE}/api/parent/notifications/mark-seen`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${getToken()}`,
    },
    body: JSON.stringify(input),
    cache: 'no-store',
  });

  const text = await res.text();
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}: ${text}`);
  return text ? JSON.parse(text) : null;
}
