import Anthropic from '@anthropic-ai/sdk';

// Keys made outside a Console workspace (sk-ant-usr-…) must name one on
// every request, or the API answers 400. Workspace keys ignore this.
export function anthropicOptions(apiKey: string) {
  const workspaceId = process.env.ANTHROPIC_WORKSPACE_ID?.trim();
  return {
    apiKey,
    ...(workspaceId
      ? { defaultHeaders: { 'anthropic-workspace-id': workspaceId } }
      : {}),
  };
}

export function getAnthropicClient() {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey || !apiKey.trim()) {
    throw new Error('ANTHROPIC_API_KEY missing');
  }
  return new Anthropic(anthropicOptions(apiKey));
}

// Alias kept so existing imports don't need updating
export const getOpenAIClient = getAnthropicClient;
