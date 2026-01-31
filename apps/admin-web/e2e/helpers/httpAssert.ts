import { APIResponse, expect } from '@playwright/test';

export async function expectOk(res: APIResponse, label = 'request') {
  const url = (res as any).url ? (res as any).url() : '';

  if (res.ok()) return;
  const text = await res.text().catch(() => '');
  throw new Error(`${label} failed: status=${res.status()} url=${url} body=${text}`);
}

export async function expectStatus(res: APIResponse, status: number, label='request') {
  if (res.status() === status) return;
  const text = await res.text().catch(() => '');
  throw new Error(`${label} expected ${status} got ${res.status()} body=${text}`);
}
