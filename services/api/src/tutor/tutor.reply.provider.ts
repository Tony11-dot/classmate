import { getOpenAIClient } from './providers/openai.provider';

function buildTonyFacts(now = new Date()): string {
  // Changeover: from "starting in Oct" -> "student at Technion"
  // Adjust date if you want exact semester start.
  const technionStart = new Date('2026-10-01T00:00:00.000Z');
  const technionLine =
    now >= technionStart ? 'CS/CE student at Technion' : 'Starting CS/CE at Technion in Oct 2026';

  return [
    'Name: Tony Aboud',
    technionLine,
    'Profile: full-stack builder; CE + CS; loves clean Apple-style UI',
    'Sports: tennis player; basketball player; sports enjoyer',
    'Music: oud player; music composer',
    'Interests: AI, physics, math, software engineering',
  ].join('\n');
}

function buildSystemPrompt(base: string, now = new Date()): string {
  return (
    base +
    `

=== STUDENT PROFILE (GENERATIVE FACTS) ===
${buildTonyFacts(now)}

=== LANGUAGE RULES ===
- Reply in the user's language.
- If user writes Arabic, reply in Arabic.
- If user writes English, reply in English.
- If mixed Arabic/English, reply in the dominant language and keep names/technical terms as-is.
- DO NOT use LaTeX delimiters like \\\( \\\), \\\[ \\\], $$, or markdown code fences for math.
- DO NOT output escaped TeX commands like \\frac, \\times, \\Omega, \\text unless the user explicitly asks for raw LaTeX.
- For normal student answers, write math in clean readable unicode/plain style exactly like:
  V = I × R
  I = V / R
  R = V / I
  4 kΩ = 4000 Ω
  20 mA = 0.02 A
- Prefer short titled sections instead of markdown heading spam.
- Keep formulas visually simple and classroom-readable, like ChatGPT-style rendered math but in plain text.
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
  const client = getOpenAIClient();
  const model = process.env.OPENAI_MODEL || 'gpt-4.1-mini';

  // ---- ClassMate context: convert DB roles -> chat roles ----
type CMRole = 'system' | 'user' | 'assistant';
const history: { role: CMRole; content: string }[] = (args.messages ?? [])
  .filter((m: any) => m && typeof (m as any).content === 'string' && String((m as any).content).trim().length)
  .map((m: any) => {
    const r = String((m as any).role || '').toUpperCase();
    let role: CMRole = 'user';
    if (r === 'ASSISTANT') role = 'assistant';
    else if (r === 'USER') role = 'user';
    else if (r === 'SYSTEM') role = 'system';
    return { role, content: String((m as any).content) };
  });

const stream = await client.chat.completions.create({
    model,
    stream: true,
    messages: [
      {
        role: 'system',
        content: buildSystemPrompt(
          `${args.system}` +
            `

=== USER CONTEXT ===
` +
            `- displayName: ${args.displayName ?? ''}
` +
            `
=== NOVA SETTINGS (CUSTOMIZABLE) ===
` +
            `${args.novaSettings ?? ''}
`,
        ),
      },
      ...(history.filter((m) => m.role !== 'system') as any),
      { role: 'user', content: args.user },
    ],
  });

  for await (const chunk of stream) {
    const delta = chunk.choices?.[0]?.delta?.content;
    if (typeof delta === 'string' && delta.length) yield delta;
  }
}
