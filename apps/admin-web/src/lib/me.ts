import { apiFetch } from './api';

export type Me = {
  user: null | {
    id: string | null;
    email: string | null;
    role: string | null;
    cohortId?: string | null;
    schoolId?: string | null;
  };
};

export async function getMe(): Promise<Me> {
  return apiFetch<Me>('/auth/me', { method: 'GET' });
}
