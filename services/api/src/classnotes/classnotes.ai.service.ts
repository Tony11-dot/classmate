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
 *   SUPPORT_AI_MODEL     (default openai/gpt-oss-120b)
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

  /**
   * The model used when the student sends a picture. Kept separate because the
   * text model can't see: pointing the snip at it returns a confident answer
   * about nothing.
   *
   * meta-llama/llama-4-scout-17b-16e-instruct (the old default) and
   * qwen/qwen3.6-27b (what SUPPORT_AI_VISION_MODEL had drifted to in prod) are
   * BOTH gone from Groq's catalog as of 2026-09-18 — every snip 404'd with
   * model_not_found regardless of which one was in play, while plain text
   * chat kept working, since that's a different model entirely. Verified
   * qwen/qwen3.8-27b directly against Groq (a real image, correctly
   * described) before making it the fallback here.
   */
  private visionModel(): string {
    return (
      process.env.SUPPORT_AI_VISION_MODEL || 'qwen/qwen3.8-27b'
    ).trim();
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

  /**
   * "See" — the student snipped a rectangle out of their page and wants to know
   * what is in it. The snip is sent as an IMAGE, not as OCR'd text, because in
   * maths and physics the part that carries the meaning is usually the part OCR
   * throws away: the diagram, the circuit, the graph, the working laid out in
   * two dimensions.
   *
   * Follow-up questions about the same snip come back through here too, with the
   * conversation so far, so "and why does that term vanish?" still has the
   * picture in front of it.
   */
  async see(
    question: string,
    imageBase64: string,
    history: { role: string; content: string }[] = [],
    pageContext?: string,
  ): Promise<{ answer: string }> {
    const ctx = (pageContext || '').trim().slice(0, ClassnotesAiService.MAX_TEXT_CHARS);
    const surface = [
      '=== THIS SURFACE: CLASSNOTES — SNIP ===',
      'The student cut a rectangle out of their own notes and is showing it to you. LOOK at it.',
      'It may be handwriting, but it may equally be a diagram, a graph, a circuit, a geometric construction, a table or a worked calculation — read whatever is actually there, including the parts that are drawn rather than written.',
      'Explain what it shows and what it means, clearly and briefly, like a friendly tutor. Define the key terms. If it is a problem, walk the steps. If something in the snip is wrong, say so kindly.',
      'Never say you cannot see an image — you can. If part of it is genuinely unreadable, say which part.',
      ctx ? `\nThe rest of the page reads:\n"""${ctx}"""` : '',
    ].join('\n');
    return this.completeWithImage(this.identity(surface), history, question, imageBase64);
  }

  /**
   * Belt-and-braces for `reasoning_format: 'hidden'`: strips any chain-of-thought
   * that still comes back inline, so a "beautify" never replaces the student's
   * handwriting with the model thinking out loud. Exported for the unit test.
   */
  static stripReasoning(raw: string): string {
    let text = raw;
    // Complete <think>…</think> (and friends), then any unterminated opener.
    text = text.replace(
      /<(think|thinking|reasoning|analysis)>[\s\S]*?<\/\1>/gi,
      '',
    );
    text = text.replace(/<(think|thinking|reasoning|analysis)>[\s\S]*$/i, '');
    // Harmony channels: keep the final channel's message, drop the rest.
    const final = text.lastIndexOf('<|channel|>final<|message|>');
    if (final >= 0) {
      text = text.slice(final + '<|channel|>final<|message|>'.length);
    }
    text = text.replace(/<\|channel\|>[a-z]*(<\|message\|>)?/gi, '');
    text = text.replace(/<\|(start|end|message|return)\|>/gi, '');
    text = text.replace(/^\s*(assistant|analysis)\s*[:\n]/i, '');
    return text.trim();
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

    const messages = [
      { role: 'system', content: system },
      ...ClassnotesAiService.trimHistory(history),
      { role: 'user', content: q },
    ];
    return this.post(messages, this.model());
  }

  /**
   * The same call with the last turn carrying a picture. Only the final user turn
   * is multimodal — the history stays plain text, which keeps a long conversation
   * about one snip from re-sending the image on every turn while still letting
   * the model see it now.
   */
  private async completeWithImage(
    system: string,
    history: { role: string; content: string }[],
    user: string,
    imageBase64: string,
  ): Promise<{ answer: string }> {
    const q =
      String(user ?? '')
        .trim()
        .slice(0, ClassnotesAiService.MAX_TEXT_CHARS) || 'Explain this.';
    const url = ClassnotesAiService.imageDataURL(imageBase64);
    const messages = [
      { role: 'system', content: system },
      ...ClassnotesAiService.trimHistory(history),
      {
        role: 'user',
        content: [
          { type: 'text', text: q },
          { type: 'image_url', image_url: { url } },
        ],
      },
    ];
    return this.post(messages, this.visionModel(), false);
  }

  /** Raw base64 or an existing data URL — both end up as a data URL. */
  static imageDataURL(imageBase64: string): string {
    const raw = String(imageBase64 ?? '').trim();
    return raw.startsWith('data:') ? raw : `data:image/jpeg;base64,${raw}`;
  }

  /** The turns worth sending: user/assistant only, recent, and bounded. */
  static trimHistory(
    history: { role: string; content: string }[],
  ): { role: string; content: string }[] {
    return (Array.isArray(history) ? history : [])
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
  }

  private static readonly RETRYABLE_STATUS = new Set([429, 500, 502, 503, 504]);

  /**
   * One retry, for exactly the two shapes of "this should have worked": a
   * transient upstream status (Groq rate-limited us, or hiccuped with a 5xx)
   * and a genuinely empty completion (a reasoning model that burned its whole
   * budget "thinking" and never reached a final answer — `reasoning_format:
   * hidden` keeps that out of `answer`, but it can still leave `answer`
   * empty). Both used to reach the student as "NOVA couldn't respond" on an
   * otherwise perfectly healthy request, indistinguishable from a real outage
   * or a dead model — which is what every other case in this file actually
   * is. A non-retryable status (400/401/404 — a contract or auth problem, not
   * a blip) and a SECOND failure in a row are both treated as the truth, not
   * tried a third time.
   */
  private async post(
    messages: unknown[],
    model: string,
    reasoning = true,
  ): Promise<{ answer: string }> {
    try {
      const answer = await this.postOnce(messages, model, reasoning);
      if (answer.trim().length > 0) return { answer };
      this.logger.warn(`Empty answer from ${model} — retrying once`);
    } catch (error) {
      const status = error instanceof UpstreamStatusError ? error.status : undefined;
      if (status !== undefined && !ClassnotesAiService.RETRYABLE_STATUS.has(status)) {
        throw new Error(`AI upstream ${status}`);
      }
      this.logger.warn(`Upstream ${status ?? 'network'} error from ${model} — retrying once`);
    }
    await new Promise((resolve) => setTimeout(resolve, 400));
    try {
      const answer = await this.postOnce(messages, model, reasoning);
      return { answer };
    } catch (error) {
      const status = error instanceof UpstreamStatusError ? error.status : undefined;
      throw new Error(`AI upstream ${status ?? 'network error'}`);
    }
  }

  /** One attempt at the upstream call, with no retry logic of its own. */
  private async postOnce(
    messages: unknown[],
    model: string,
    reasoning: boolean,
  ): Promise<string> {
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
          model,
          temperature: 0.3,
          messages,
          // See ai.service.ts: gpt-oss narrates its reasoning by default, which
          // ended up inside `answer` — and for "beautify" that meant the model's
          // thoughts replacing the student's handwriting. Sent only to the
          // reasoning model: Groq rejects the parameter outright on models that
          // don't support it, which would turn every snip into an upstream 400.
          ...(reasoning
            ? { reasoning_format: 'hidden', reasoning_effort: 'low' }
            : {}),
        }),
        signal: controller.signal,
      });
      if (!res.ok) {
        throw new UpstreamStatusError(res.status);
      }
      const data: any = await res.json();
      return ClassnotesAiService.stripReasoning(
        String(data?.choices?.[0]?.message?.content ?? ''),
      );
    } finally {
      clearTimeout(timer);
    }
  }
}

/** Carries the upstream HTTP status through `post`'s retry decision. */
class UpstreamStatusError extends Error {
  constructor(readonly status: number) {
    super(`AI upstream ${status}`);
  }
}
