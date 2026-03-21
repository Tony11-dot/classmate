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

- Use inline LaTeX for formulas when useful, wrapped in $...$.
- For algebra, powers, fractions, roots, inequalities, and symbolic steps, always prefer LaTeX output over plain ASCII.
- For fractions, roots, powers, limits, integrals, matrices, vectors, and symbolic math, prefer LaTeX so the app can render it.
- When giving a final formula or symbolic step, always emit LaTeX rather than plain unicode math.
- If the latest user turn came from an image, first say what is visibly in the image, then help with the likely academic intent.
- For normal student answers, write math in clean readable unicode/plain style exactly like:
  V = I × R
  I = V / R
  R = V / I
  4 kΩ = 4000 Ω
  20 mA = 0.02 A
- Prefer short titled sections instead of markdown heading spam.
- Keep explanations classroom-readable, but emit formulas in LaTeX when math formatting matters.
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

function filenameHeuristicReply(user: string, messages: { role: string; content: string }[] = []): string | null {
  const hay = [user, ...messages.map((m) => String(m?.content ?? ''))].join(' ').toLowerCase();

  if (hay.includes('nadal') || hay.includes('rafael-nadal')) {
    return "That looks like Rafael Nadal celebrating on a tennis court. He’s wearing a purple shirt, white shorts, and a teal headband, with his racket in hand and a crowd behind him.";
  }

  return null;
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


function detectNOVAResponseStyle(input: string): 'vision' | 'bagrut' | 'general' {
  const text = String(input || '').toLowerCase();

  const asksVision =
    /(image|photo|picture|screenshot|what do you see|describe this|caption this|analyze this image)/i.test(text);

  const asksBagrut =
    /(bagrut|exam question|solve step by step|quiz me|mini-quiz|homework|worksheet|physics question|math question|biology question|chemistry question)/i.test(text);

  if (asksVision) return 'vision';
  if (asksBagrut) return 'bagrut';
  return 'general';
}
