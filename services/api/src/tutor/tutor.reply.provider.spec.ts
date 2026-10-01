import { computeCost } from '../billing/cost.model';

const stream = jest.fn();
jest.mock('./providers/openai.provider', () => ({
  getAnthropicClient: () => ({ messages: { stream } }),
}));

import { generateAssistantReplyStream, StreamUsageReport } from './tutor.reply.provider';

async function* fakeEvents() {
  yield {
    type: 'message_start',
    message: { usage: { input_tokens: 50, cache_read_input_tokens: 4000, cache_creation_input_tokens: 300, output_tokens: 1 } },
  };
  yield { type: 'content_block_delta', delta: { type: 'text_delta', text: 'hi' } };
  yield { type: 'message_delta', usage: { output_tokens: 20 } };
}

async function run(args: Partial<Parameters<typeof generateAssistantReplyStream>[0]>) {
  stream.mockReturnValue(fakeEvents());
  let usage: StreamUsageReport | undefined;
  const out: string[] = [];
  for await (const d of generateAssistantReplyStream({
    system: 'base',
    user: 'what is 2+2?',
    tier: 'BALANCE',
    onUsage: (u) => (usage = u),
    ...args,
  })) out.push(d);
  return { body: stream.mock.calls[0][0], usage, out };
}

describe('generateAssistantReplyStream', () => {
  it('does not send the latest user message twice and caches the conversation', async () => {
    const { body } = await run({
      messages: [
        { role: 'USER', content: 'hello' },
        { role: 'ASSISTANT', content: 'hi there' },
        { role: 'USER', content: 'what is 2+2?\n[Attachment context]' },
      ],
    });
    expect(body.messages).toHaveLength(3);
    const final = body.messages[2];
    expect(final.role).toBe('user');
    // The DB copy (with attachment context) wins over the bare `user` string.
    expect(final.content[0].text).toBe('what is 2+2?\n[Attachment context]');
    expect(final.content[0].cache_control).toEqual({ type: 'ephemeral' });
    expect(body.system[0].cache_control).toEqual({ type: 'ephemeral' });
  });

  it('appends `user` when history does not end with a user turn', async () => {
    const { body } = await run({ messages: [{ role: 'ASSISTANT', content: 'hi' }] });
    expect(body.messages.map((m: any) => m.role)).toEqual(['assistant', 'user']);
    expect(body.messages[1].content[0].text).toBe('what is 2+2?');
  });

  it('puts the turn note after the cache breakpoint, outside the system prompt', async () => {
    const { body } = await run({ messages: [], turnNote: 'GRADE_ONLY' });
    const final = body.messages[body.messages.length - 1];
    expect(final.content).toHaveLength(2);
    expect(final.content[0].cache_control).toBeDefined();
    expect(final.content[1]).toEqual({ type: 'text', text: 'GRADE_ONLY' });
    expect(JSON.stringify(body.system)).not.toContain('GRADE_ONLY');
  });

  it('reports cache writes in usage', async () => {
    const { usage, out } = await run({ messages: [] });
    expect(out.join('')).toBe('hi');
    expect(usage).toMatchObject({ inputTokens: 50, cachedInputTokens: 4000, cacheWriteTokens: 300, outputTokens: 20 });
  });
});

describe('computeCost', () => {
  it('prices cache writes at 1.25x input without charging the user for them', () => {
    const withoutWrites = computeCost('claude-sonnet-4-6', 0, 0, 0);
    const withWrites = computeCost('claude-sonnet-4-6', 0, 0, 0, 1_000_000);
    expect(withoutWrites.costUsd).toBe(0);
    expect(withWrites.costUsd).toBeCloseTo(3.75);
    expect(withWrites.tokensCharged).toBe(0);
  });
});
