import Anthropic from '@anthropic-ai/sdk';

export function getAnthropicClient() {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (!apiKey || !apiKey.trim()) {
    throw new Error('ANTHROPIC_API_KEY missing');
  }
  return new Anthropic({ apiKey });
}

// Alias kept so existing imports don't need updating
export const getOpenAIClient = getAnthropicClient;
