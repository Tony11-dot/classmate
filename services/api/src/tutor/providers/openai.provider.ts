import OpenAI from 'openai';

export function getOpenAIClient() {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey || !apiKey.trim()) {
    throw new Error('OPENAI_API_KEY missing');
  }
  return new OpenAI({ apiKey });
}
