import { Injectable, Logger } from '@nestjs/common';
import {
  NOVA_IDENTITY,
  NOVA_LANGUAGE_RULES,
  NOVA_CLASSNOTES_FACTS,
} from '../common/nova-identity';

/**
 * A free, self-serve support assistant.
 *
 * It answers ClassMate how-to / troubleshooting questions in-app, in ADDITION
 * to the static FAQ + human contact channels on the Support screen. It is a
 * deliberately separate concern from NOVA (the metered Anthropic study tutor):
 * NOVA teaches, this only knows the product and always defers a real problem to
 * the human support channel.
 *
 * Provider-agnostic: it speaks the OpenAI-compatible Chat Completions API, so
 * the same code works against Groq (the chosen default — a genuinely free
 * hosted tier), a self-hosted Ollama, OpenRouter, etc. Pick one purely with
 * env vars:
 *   SUPPORT_AI_BASE_URL  (default https://api.groq.com/openai/v1)
 *   SUPPORT_AI_API_KEY   (falls back to GROQ_API_KEY; blank for keyless Ollama)
 *   SUPPORT_AI_MODEL     (default llama-3.3-70b-versatile)
 *
 * When no key is configured (and the base URL isn't a keyless local one) the
 * assistant reports itself disabled so the app hides it and keeps showing the
 * FAQ + contact card exactly as before — nothing breaks if the key is missing.
 */
@Injectable()
export class SupportService {
  private readonly logger = new Logger('SupportService');

  private static readonly MAX_QUESTION_CHARS = 2000;
  private static readonly MAX_HISTORY_TURNS = 8;
  private static readonly MAX_HISTORY_CHARS = 2000;
  private static readonly REQUEST_TIMEOUT_MS = 25_000;

  private baseUrl(): string {
    return (process.env.SUPPORT_AI_BASE_URL || 'https://api.groq.com/openai/v1')
      .trim()
      .replace(/\/+$/, '');
  }

  private apiKey(): string {
    return (process.env.SUPPORT_AI_API_KEY || process.env.GROQ_API_KEY || '').trim();
  }

  private model(): string {
    // llama-3.3-70b-versatile was deprecated by Groq on 2026-06-17.
    return (process.env.SUPPORT_AI_MODEL || 'openai/gpt-oss-120b').trim();
  }

  /**
   * Whether the assistant can actually answer. A hosted provider needs a key;
   * a local Ollama-style endpoint (localhost / 127.0.0.1) is treated as keyless
   * so self-hosters don't need to invent one.
   */
  isEnabled(): boolean {
    if (this.apiKey()) return true;
    const host = this.baseUrl().toLowerCase();
    return host.includes('localhost') || host.includes('127.0.0.1');
  }

  private systemPrompt(): string {
    return [
      NOVA_IDENTITY,
      '',
      NOVA_CLASSNOTES_FACTS,
      '',
      NOVA_LANGUAGE_RULES,
      '',
      '=== THIS SURFACE: SUPPORT ===',
      'Right now you are NOVA in SUPPORT mode — the in-app helper on the Support screen. Same NOVA, same name, same home, different job: here you help people USE ClassMate rather than tutoring them through schoolwork.',
      'If someone asks who you are, you are NOVA — you do not have a different name in this mode, and you are not a separate assistant from the NOVA who tutors.',
      '',
      'YOUR JOB:',
      '- Answer questions about how to USE ClassMate: logging in, resetting a password, changing email/phone, schedules, grades, attendance, classrooms, assignments, materials, messages, announcements, forms, diplomas/certificates, cohorts, and school setup.',
      '- Give short, concrete, step-by-step answers. Point users to where a feature lives (e.g. "open the drawer / side menu, then Settings").',
      '- Keep answers brief and practical. Use simple Markdown (short lists, bold) when it helps.',
      '- Be warm and personable — you are NOVA, not a form. A question about you, ClassMate, or the people who built it is perfectly on-topic: answer it happily and briefly, then offer help.',
      '',
      'WHAT YOU KNOW ABOUT THE APP:',
      '- Sign in: tap "Sign in" and use the email or username the school administrator issued, plus the temporary password; you are prompted to set a new password on first login.',
      '- Forgot password: tap "Forgot password?" on the login screen to get an email reset link or an SMS code. If neither is verified, the school administrator can issue a new temporary password.',
      '- Change password: Profile → Security → password row (needs the current password).',
      '- Change email/phone: Profile → tap the field → a code is sent to the CURRENT email/phone first to confirm identity, then set the new value.',
      '- Languages: English, Arabic, Hebrew, French, Russian — switch in Settings. Themes and appearance are also in Settings.',
      '- Accounts are created by the school administrator (or via a join code where self-enrolment is enabled). Teachers add students to classrooms directly or via a join code (Classrooms → "Join with code").',
      '- Students: Schedule, Grades, Attendance, Classrooms, Assignments, Materials, Messages, Announcements, Forms, Diplomas all live in the drawer. NOVA is the separate AI study tutor (drawer → Nova).',
      '- Teachers: create classrooms (Classrooms → +), mark attendance (Attendance), set homework (Assignments → +), issue diplomas (Diplomas → +).',
      '- Administrators: the Admin Dashboard has a School Setup checklist (logo, name, subjects, bell schedule, cohorts, students, teachers). Cohorts group students that share a schedule.',
      '- Parents linked to a student see that student’s grades and attendance.',
      '',
      'IMPORTANT RULES:',
      '- You are NOT NOVA (the study tutor) and you do NOT do homework, solve academic problems, or write essays. If asked, briefly redirect to NOVA and stay on support topics.',
      '- Only describe features listed above; never invent screens, buttons, or capabilities. If you are unsure or the answer is not about using ClassMate, say so plainly.',
      '- For anything you cannot resolve — a bug, a broken account, billing, a data/privacy request, or reaching a human — tell the user to email support@classmateapp.org (the human support team replies within a working day). Do not promise actions you cannot perform.',
      '- Never ask for or repeat passwords, verification codes, or other secrets.',
    ].join('\n');
  }

  /**
   * Answer a single support question with optional prior turns for context.
   * Returns the assistant text; throws only on a genuine upstream failure so
   * the controller can surface a friendly error.
   */
  async ask(
    question: string,
    history: { role: string; content: string }[] = [],
  ): Promise<{ answer: string }> {
    const q = String(question ?? '').trim().slice(0, SupportService.MAX_QUESTION_CHARS);

    const trimmedHistory = (Array.isArray(history) ? history : [])
      .filter(
        (m) =>
          m &&
          (m.role === 'user' || m.role === 'assistant') &&
          typeof m.content === 'string' &&
          m.content.trim().length > 0,
      )
      .slice(-SupportService.MAX_HISTORY_TURNS)
      .map((m) => ({
        role: m.role === 'assistant' ? 'assistant' : 'user',
        content: m.content.trim().slice(0, SupportService.MAX_HISTORY_CHARS),
      }));

    const messages = [
      { role: 'system', content: this.systemPrompt() },
      ...trimmedHistory,
      { role: 'user', content: q },
    ];

    const controller = new AbortController();
    const timer = setTimeout(
      () => controller.abort(),
      SupportService.REQUEST_TIMEOUT_MS,
    );

    try {
      const res = await fetch(`${this.baseUrl()}/chat/completions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(this.apiKey() ? { Authorization: `Bearer ${this.apiKey()}` } : {}),
        },
        body: JSON.stringify({
          model: this.model(),
          messages,
          temperature: 0.3,
          max_tokens: 700,
        }),
        signal: controller.signal,
      });

      if (!res.ok) {
        // Never leak the upstream body (may contain the key/provider details).
        const status = res.status;
        this.logger.warn(`support_ai_upstream_error status=${status}`);
        throw new Error(`Support AI upstream error (${status})`);
      }

      const data: any = await res.json();
      const answer = String(data?.choices?.[0]?.message?.content ?? '').trim();
      if (!answer) {
        throw new Error('Support AI returned an empty response');
      }
      return { answer };
    } finally {
      clearTimeout(timer);
    }
  }
}
