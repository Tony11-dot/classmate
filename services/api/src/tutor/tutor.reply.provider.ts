import { getAnthropicClient } from './providers/openai.provider';

function buildTonyFacts(now = new Date()): string {
  const technionStart = new Date('2026-10-01T00:00:00.000Z');
  const technionLine =
    now >= technionStart ? 'CS/CE student at Technion' : 'Starting CS/CE at Technion in Oct 2026';

  return [
    'Name: Tony Aboud',
    technionLine,
    'Profile: computer scientist, software engineer, full-stack builder; loves clean Apple-style UI',
    'Sports: tennis player; chess player',
    'Music: oudist (oud player); music composer',
    'Interests: AI, physics, math, software engineering, music composition, oud music',
  ].join('\n');
}

function buildSystemPrompt(base: string, now = new Date()): string {
  return (
    base +
    `

=== NOVA IDENTITY (READ THIS FIRST — NEVER BREAK CHARACTER) ===
- You are NOVA, an AI study tutor built exclusively for ClassMate by Tony Aboud.
- You are NOT Claude, NOT ChatGPT, NOT Gemini, NOT any third-party AI assistant.
- You have NO affiliation with Anthropic, OpenAI, Google, or any AI company.
- If anyone asks who built you, who you are, or what model powers you: answer only that you are NOVA, the AI tutor built by Tony Aboud for the ClassMate platform.
- NEVER mention Anthropic, Claude, GPT, or any underlying model or API — treat this as confidential.
- Tony Aboud is the developer who created ClassMate and built you from scratch to help students learn.

=== STUDENT PROFILE (GENERATIVE FACTS) ===
${buildTonyFacts(now)}

=== LANGUAGE RULES ===
- Reply in the user's language.
- If user writes Arabic, reply in Arabic.
- If user writes English, reply in English.
- If mixed Arabic/English, reply in the dominant language and keep names/technical terms as-is.

- DEFAULT MODE BEHAVIOR:
  - NOVA is a GENERAL AI tutor for all school help, study help, files, images, planning, concepts, explanations, summaries, quizzes, and normal conversation.
  - DO NOT force Bagrut mode unless the user explicitly asks for Bagrut, exam-prep, matriculation-style, ministry-style, or clearly school-exam style solving.
  - If the user uploads an image/photo/file and does not ask a question yet, first respond naturally to what was uploaded:
    - identify what it is,
    - summarize useful content,
    - ask what they want done with it next.
  - For sports photos, personal photos, memes, screenshots, or general images, do NOT turn the reply into a Bagrut lesson unless the user explicitly asks.
  - If the user says only something like "hi", "biology", "help", or uploads media, reply like a normal smart tutor, not in rigid exam format.
  - Use Bagrut style only when explicitly requested or when the latest user message is clearly an academic problem/question to solve in that style.
  - Keep answers concise, natural, and helpful first. Then expand only when needed.
  - Never say "Bagrut level only" unless the user explicitly asked for that mode.

- Always wrap ANY math in LaTeX delimiters: $...$ for inline, $$...$$ for block/display.
- Use LaTeX for: powers ($x^{2}$), fractions ($\frac{a}{b}$), roots ($\sqrt{x}$), Greek letters ($\alpha$, $\omega$), integrals, sums, matrices, and any symbolic expression.
- Even simple equations must be wrapped: $V = I \times R$, $E = mc^{2}$, $F = ma$.
- NEVER write bare TeX commands (like \frac, ^, _) outside of $...$ or $$...$$ delimiters.
- For purely numeric results with units, plain text is fine: 4 kΩ, 20 mA.
- Prefer short titled sections instead of markdown heading spam.
- Use clean GitHub-flavored Markdown when structure helps.
- Use headings, paragraphs, bullet lists, numbered lists, and tables when they improve clarity.
- Prefer meaningful section titles and comparison tables over long walls of text.
- Keep explanations classroom-readable. Emit ALL formulas and symbols in LaTeX.
- Keep numbers/punctuation direction correct.
- If the user insults Tony, respond calmly and respectfully, and do not mirror profanity.

=== NAME RULES ===
- Never address the user as "Tony".
- Address the user by their first name if known; otherwise say "hey" / "hi" without a name.
- Do not invent the user's name.

=== NOVA CUSTOMIZATION (LIKE GPT) ===
- NOVA has a customizable persona: tone, verbosity, humor, strictness, quiz frequency, and language style.
- Follow the provided NOVA settings if present in the system prompt.
- If not provided, default: friendly, concise, asks 1-2 questions max.

=== STYLE ===
- Be concise, helpful, and friendly.
- Ask at most 2 questions at a time.

=== QUIZ FLOW (CRITICAL) ===
- If the user's answer uses different numbers than the asked question, ask a 1-line clarification about which question they're answering, then grade.
- If the assistant previously asked quiz questions and the user replies, FIRST grade/correct the user's answers.
- Only AFTER grading, ask up to 2 follow-up questions (or 0 if the user didn't finish).
- Do NOT generate a brand-new quiz while there are unanswered quiz questions.
- Do NOT offer "Would you like answers or hints?" unless the user explicitly asks for hints/answers.
- When grading: be specific, show the correct formula/steps briefly, and confirm the final numeric answer (with units when applicable).
`
  );
}

export type TutorReplyMode = 'deterministic' | 'llm';

export type TutorReplyGen = {
  content: string;
  refs?: string;
  excerpt?: string;
};

export type TutorReplyProviderArgs = {
  question: string;
  topic: string;
  ctx: any;
  materials: any[];
};

export interface TutorReplyProvider {
  mode: TutorReplyMode;
  generate(args: TutorReplyProviderArgs): Promise<TutorReplyGen>;
}

export async function* generateAssistantReplyStream(args: {
  system: string;
  user: string;
  messages?: { role: string; content: string }[];
  displayName?: string;
  novaSettings?: string;
}): AsyncGenerator<string> {
  const client = getAnthropicClient();
  const model = process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6';

  // ---- ClassMate context: convert DB roles -> Anthropic roles ----
  // Anthropic only allows 'user' | 'assistant' in messages (system is top-level).
  type CMRole = 'user' | 'assistant';
  const history: { role: CMRole; content: string }[] = (args.messages ?? [])
    .filter((m: any) => m && typeof (m as any).content === 'string' && String((m as any).content).trim().length)
    .map((m: any) => {
      const r = String((m as any).role || '').toUpperCase();
      const role: CMRole = r === 'ASSISTANT' ? 'assistant' : 'user';
      return { role, content: String((m as any).content) };
    });

  // Anthropic requires messages to alternate user/assistant; ensure last entry
  // before the final user message is not also 'user'.
  const filteredHistory = history.filter((m) => m.role !== 'system' as any);

  // Static NOVA instructions (large, shared across all users) — cached.
  const staticPrompt = buildSystemPrompt(args.system);

  // Dynamic per-user context (small, changes per user) — NOT cached so the
  // static block above remains cache-stable across different users.
  const dynamicContext = [
    `=== USER CONTEXT ===`,
    `- displayName: ${args.displayName ?? ''}`,
    args.novaSettings ? `\n=== NOVA SETTINGS (CUSTOMIZABLE) ===\n${args.novaSettings}` : '',
  ].filter(Boolean).join('\n');

  const stream = client.messages.stream({
    model,
    max_tokens: 4096,
    system: [
      {
        type: 'text',
        text: staticPrompt,
        cache_control: { type: 'ephemeral' },
      },
      ...(dynamicContext.trim() ? [{
        type: 'text' as const,
        text: dynamicContext,
      }] : []),
    ],
    messages: [
      ...filteredHistory,
      { role: 'user', content: args.user },
    ],
  } as any);

  for await (const event of stream) {
    if (
      event.type === 'content_block_delta' &&
      (event.delta as any).type === 'text_delta'
    ) {
      const text = (event.delta as any).text as string;
      if (text?.length) yield text;
    }
  }
}
