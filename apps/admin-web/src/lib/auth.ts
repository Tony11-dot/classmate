import { apiFetch, setToken, clearToken } from './api';

export type LoginResponse = { token: string };

export async function login(email: string, password: string) {
  const res = await apiFetch<LoginResponse>('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
  setToken(res.token);
  return res.token;
}

export function logout() {
  clearToken();
}
