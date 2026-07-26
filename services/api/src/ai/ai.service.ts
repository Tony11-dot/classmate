import { Injectable, Logger } from '@nestjs/common';
import {
  NOVA_IDENTITY,
  NOVA_LANGUAGE_RULES,
  NOVA_CLASSNOTES_FACTS,
} from '../common/nova-identity';

/**
 * OpenAI-compatible streaming proxy for NOVA in the ClassNotes app.
 *
 * The native app speaks the Chat Completions API and, in "proxy" mode, sends
 * the user's ClassMate JWT as the bearer instead of a model key. This service
 * holds the real key server-side (Groq by default, same env vars as the Support
 * assistant), injects NOVA's identity so she never breaks character or leaks the
 * provider, and streams the upstream SSE straight back to the client.
 *
 *   SUPPORT_AI_BASE_URL  (default https://api.groq.com/openai/v1)
 *   SUPPORT_AI_API_KEY   (falls back to GROQ_API_KEY)
 *   SUPPORT_AI_MODEL     (default llama-3.3-70b-versatile)
 *   SUPPORT_AI_VISION_MODEL (default a Groq vision model, for the magic pen)
 */
@Injectable()
export class AiService {
  private readonly logger = new Logger('AiService');

  private baseUrl(): string {
    return (process.env.SUPPORT_AI_BASE_URL || 'https://api.groq.com/openai/v1')
      .trim()
      .replace(/\/+$/, '');
  }

  private apiKey(): string {
    return (process.env.SUPPORT_AI_API_KEY || process.env.GROQ_API_KEY || '').trim();
  }

  private textModel(): string {
    return (process.env.SUPPORT_AI_MODEL || 'openai/gpt-oss-120b').trim();
  }

  private visionModel(): string {
    // Groq multimodal model (text + image). The old llama-4-scout/​maverick and
    // llama-3.3 models were deprecated by Groq on 2026-06-17.
    return (process.env.SUPPORT_AI_VISION_MODEL || 'qwen/qwen3.6-27b').trim();
  }

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
      '=== THIS SURFACE: CLASSNOTES ===',
      'You are NOVA inside the ClassNotes note-taking app, helping a student understand and improve their own notes. Be warm, clear and concise. Explain highlighted text, summarise, define terms, and quiz when asked. Use simple Markdown. When a student circles a region of their notes, read it and explain it plainly, then offer one useful follow-up.',
    ].join('\n');
  }

  /**
   * Whether any message carries an image part (the magic pen) → route to the
   * vision model. We never trust the client's raw model string (that would make
   * this an open proxy to arbitrary models); we pick one of our two ourselves.
   */
  private hasImage(messages: any[]): boolean {
    return (
      Array.isArray(messages) &&
      messages.some(
        (m) =>
          Array.isArray(m?.content) &&
          m.content.some((p: any) => p?.type === 'image_url'),
      )
    );
  }

  /**
   * Call the upstream model and return the raw streaming Response so the
   * controller can pipe the SSE bytes straight through. Forces our own model +
   * identity; passes the client's messages and sampling through.
   */
  async streamChat(body: any): Promise<Response> {
    const clientMessages: any[] = Array.isArray(body?.messages) ? body.messages : [];
    // Drop any client-sent system message; NOVA's identity is authoritative.
    const nonSystem = clientMessages.filter((m) => m?.role !== 'system');
    const messages = [{ role: 'system', content: this.systemPrompt() }, ...nonSystem];

    const model = this.hasImage(nonSystem) ? this.visionModel() : this.textModel();
    const temperature =
      typeof body?.temperature === 'number' ? Math.max(0, Math.min(1, body.temperature)) : 0.4;

    return fetch(`${this.baseUrl()}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.apiKey() ? { Authorization: `Bearer ${this.apiKey()}` } : {}),
      },
      body: JSON.stringify({ model, stream: true, temperature, messages }),
    });
  }
}
