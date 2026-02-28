import { APIRequestContext, Page } from '@playwright/test';

const API_BASE = (process.env.E2E_API_BASE_URL && process.env.E2E_API_BASE_URL.trim()) ? process.env.E2E_API_BASE_URL : 'http://127.0.0.1:3001';

export async function apiLogin(
  request: APIRequestContext,
  email: string,
  password: string
) {
  const resp = await request.post(`${API_BASE}/api/auth/login`, {
    data: { email, password },
  });

  if (resp.status() !== 201) {
    throw new Error(`Login failed (${email}): ${resp.status()}`);
  }

  const body = await resp.json();
  if (!body.token) throw new Error(`No token returned for ${email}`);

  return body.token as string;
}

export async function loginAsTeacher(page: Page, request: APIRequestContext) {
  const token = await apiLogin(request, 'teacher1@classmate.app', 'dev');

  await page.addInitScript(({ token }) => {
    localStorage.setItem('auth_token', token);
  }, { token });
}

export async function loginAsAdmin(page: Page, request: APIRequestContext) {
  const token = await apiLogin(request, 'admin1@classmate.app', 'dev');

  await page.addInitScript(({ token }) => {
    localStorage.setItem('auth_token', token);
  }, { token });
}
