import { anthropicOptions } from './openai.provider';

describe('anthropicOptions', () => {
  const saved = process.env.ANTHROPIC_WORKSPACE_ID;
  afterEach(() => {
    if (saved === undefined) delete process.env.ANTHROPIC_WORKSPACE_ID;
    else process.env.ANTHROPIC_WORKSPACE_ID = saved;
  });

  it('sends no workspace header by default', () => {
    delete process.env.ANTHROPIC_WORKSPACE_ID;
    expect(anthropicOptions('k')).toEqual({ apiKey: 'k' });
  });

  it('names the workspace when ANTHROPIC_WORKSPACE_ID is set', () => {
    process.env.ANTHROPIC_WORKSPACE_ID = ' wrkspc_test ';
    expect(anthropicOptions('k')).toEqual({
      apiKey: 'k',
      defaultHeaders: { 'anthropic-workspace-id': 'wrkspc_test' },
    });
  });
});
