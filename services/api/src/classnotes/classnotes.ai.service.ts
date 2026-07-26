import { Injectable, Logger } from '@nestjs/common';
import {
  NOVA_IDENTITY,
  NOVA_LANGUAGE_RULES,
  NOVA_CLASSNOTES_FACTS,
} from '../common/nova-identity';

/**
 * NOVA for the ClassNotes note-taking app — the AI behind "explain what I
 * highlighted", "beautify my handwriting", and general note help.
 *
 * It is a server-side proxy so the native app never holds an API key: the app
 * sends the (already OCR'd) text with a task, we call the model, and return the
 * result. Same free, OpenAI-compatible engine as the Support assistant (Groq by
 * default) — configured purely with env vars, identical to SupportService:
 *   SUPPORT_AI_BASE_URL  (default https://api.groq.com/openai/v1)
 *   SUPPORT_AI_API_KEY   (falls back to GROQ_API_KEY)
 *   SUPPORT_AI_MODEL     (default llama-3.3-70b-versatile)
 *
 * Every route is JWT-gated (ALL_APP_ROLES) so it's never an open AI endpoint.
 */
@Injectable()
export class ClassnotesAiService {
  private readonly logger = new Logger('ClassnotesAiService');

  private static readonly MAX_TEXT_CHARS = 6000;
  private static readonly MAX_HISTORY_TURNS = 8;
  private static readonly MAX_HISTORY_CHARS = 2000;
  private static readonly REQUEST_TIMEOUT_MS = 30_000;

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

  isEnabled(): boolean {
    if (this.apiKey()) return true;
    const host = this.baseUrl().toLowerCase();
    return host.includes('localhost') || host.includes('127.0.0.1');
  }

  private identity(surface: string): string {
    return [NOVA_IDENTITY, '', NOVA_CLASSNOTES_FACTS, '', NOVA_LANGUAGE_RULES, '', surface].join(
      '\n',
    );
  }

  /**
   * "Beautify" — clean up the student's OWN handwritten words into tidy, correct
   * text WITHOUT changing meaning, adding content, or commenting. Returns only
   * the rewritten note text (the app replaces the ink with it in place).
   */
  async beautify(text: string): Promise<{ answer: string }> {
    const surface = [
      '=== THIS SURFACE: CLASSNOTES — BEAUTIFY ===',
      'The student wrote the text below by hand in their ClassNotes notebook and asked you to tidy it up.',
      'Rewrite it into clean, correct, well-punctuated text that says EXACTLY what they meant — same language, same facts, same intent.',
      'Fix spelling, capitalisation, spacing and obvious grammar. Keep their voice. Preserve line breaks / list structure where it makes sense.',
      'Do NOT add new information, do NOT answer or explain, do NOT add greetings, headings, quotes, or any commentary.',
      'Output ONLY the cleaned-up note text — nothing else.',
    ].join('\n');
    return this.complete(this.identity(surface), [], `Tidy up this note:\n\n${text}`);
  }

  /**
   * "Explain" — the student highlighted/circled something on the page. Give a
   * short, clear explanation a student can learn from.
   */
  async explain(text: string): Promise<{ answer: string }> {
    const surface = [
      '=== THIS SURFACE: CLASSNOTES — EXPLAIN ===',
      'The student highlighted the text/notes below in their ClassNotes notebook and wants to understand it.',
      'Explain it clearly and briefly, like a friendly tutor. Define key terms, and give a simple example if it helps.',
      'Keep it focused on what they highlighted. Use short paragraphs or a small list; simple Markdown is fine.',
    ].join('\n');
    return this.complete(this.identity(surface), [], `Explain this:\n\n${text}`);
  }

  /**
   * General NOVA chat inside ClassNotes — study help grounded in the note the
   * student is looking at (optional page context).
   */
  async chat(
    question: string,
    history: { role: string; content: string }[] = [],
    pageContext?: string,
  ): Promise<{ answer: string }> {
    const ctx = (pageContext || '').trim().slice(0, ClassnotesAiService.MAX_TEXT_CHARS);
    const surface = [
      '=== THIS SURFACE: CLASSNOTES — STUDY HELP ===',
      'You are NOVA inside the ClassNotes note-taking app, helping a student with their notes and schoolwork.',
      'Be warm, concise and genuinely helpful. Explain, summarise, define, and quiz when asked. Use simple Markdown.',
      ctx ? `\nThe student is looking at this page (their own notes) — use it as context:\n"""${ctx}"""` : '',
    ].join('\n');
    return this.complete(this.identity(surface), history, question);
  }

  /** Shared OpenAI-compatible chat-completions call (non-streaming). */
  private async complete(
    system: string,
    history: { role: string; content: string }[],
    user: string,
  ): Promise<{ answer: string }> {
    const q = String(user ?? '')
      .trim()
      .slice(0, ClassnotesAiService.MAX_TEXT_CHARS);

    const trimmedHistory = (Array.isArray(history) ? history : [])
      .filter(
        (m) =>
          m &&
          (m.role === 'user' || m.role === 'assistant') &&
          typeof m.content === 'string' &&
          m.content.trim().length > 0,
      )
      .slice(-ClassnotesAiService.MAX_HISTORY_TURNS)
      .map((m) => ({
        role: m.role === 'assistant' ? 'assistant' : 'user',
        content: m.content.trim().slice(0, ClassnotesAiService.MAX_HISTORY_CHARS),
      }));

    const messages = [
      { role: 'system', content: system },
      ...trimmedHistory,
      { role: 'user', content: q },
    ];

    const controller = new AbortController();
    const timer = setTimeout(
      () => controller.abort(),
      ClassnotesAiService.REQUEST_TIMEOUT_MS,
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
          temperature: 0.3,
          messages,
        }),
        signal: controller.signal,
      });
      if (!res.ok) {
        throw new Error(`AI upstream ${res.status}`);
      }
      const data: any = await res.json();
      const answer = String(data?.choices?.[0]?.message?.content ?? '').trim();
      return { answer };
    } finally {
      clearTimeout(timer);
    }
  }
}
