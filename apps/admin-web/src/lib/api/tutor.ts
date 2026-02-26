import { apiFetch } from './client';
import type {
  TutorSession,
  CreateSessionInput,
  TutorReplyResponse
} from '@classmate/contracts';

export function createTutorSession(
  data: CreateSessionInput
): Promise<{ session: TutorSession }> {
  return apiFetch('/tutor/sessions', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

export function getTutorSessions(): Promise<{ sessions: TutorSession[] }> {
  return apiFetch('/tutor/sessions');
}

export function sendTutorReply(
  sessionId: string,
  prompt: string
): Promise<TutorReplyResponse> {
  return apiFetch(`/tutor/sessions/${sessionId}/reply`, {
    method: 'POST',
    body: JSON.stringify({ prompt }),
  });
}
