// Anthropic API pricing — USD per million tokens.
//
// Update when Anthropic changes prices. The TokensService uses these
// to compute per-call cost for the TokenUsage audit table, so
// per-user margin reports stay accurate without re-deriving from the
// Anthropic dashboard.
//
// Cached input is read pricing (10% of standard input). Cache writes
// charge 1.25x standard input the FIRST time a cache block is written,
// but we don't track writes separately yet — the overhead amortises
// across the cache TTL (5 minutes for Anthropic) so for steady-state
// chats the read price dominates.

export interface ModelPricing {
  inputPerM: number;
  cachedInputPerM: number; // cache-read price
  outputPerM: number;
}

export const MODEL_PRICING: Record<string, ModelPricing> = {
  // Claude Sonnet 4.6 — kept so historical TokenUsage rows still re-price correctly.
  // No longer the default model; see pricingForModel() below.
  'claude-sonnet-4-6': {
    inputPerM: 3.0,
    cachedInputPerM: 0.3,
    outputPerM: 15.0,
  },
  // Claude Haiku 4.5 — primary model for NOVA + Practice (all tiers).
  'claude-haiku-4-5': {
    inputPerM: 1.0,
    cachedInputPerM: 0.1,
    outputPerM: 5.0,
  },
  // Claude Haiku 4.5 explicit-date alias.
  'claude-haiku-4-5-20251001': {
    inputPerM: 1.0,
    cachedInputPerM: 0.1,
    outputPerM: 5.0,
  },
  // Claude Opus 4.7 — kept for completeness; not yet wired into NOVA but
  // we'd want the pricing already mapped if a future "Pro mode" toggles it.
  'claude-opus-4-7': {
    inputPerM: 15.0,
    cachedInputPerM: 1.5,
    outputPerM: 75.0,
  },
};

export interface CostBreakdown {
  /// USD spent on this single call.
  costUsd: number;
  /// Total tokens we charge against the user's balance. Defaults to
  /// input + output, but we MULTIPLY output by 5 (the rough cost ratio
  /// of output:input for Sonnet) so users on a token budget can't
  /// trivially game the system by asking for very long replies. Without
  /// this weighting a user could ask "summarise War and Peace" and burn
  /// pure profit on output tokens at the input-token rate.
  tokensCharged: number;
}

export function pricingForModel(model: string): ModelPricing {
  const lookup = MODEL_PRICING[model];
  if (lookup) return lookup;
  // Unknown model — fall back to Haiku pricing (current default model).
  return MODEL_PRICING['claude-haiku-4-5-20251001'];
}

/// Per-call cost + token-charge calculator. `inputTokens` is the
/// non-cached portion; `cachedInputTokens` is reused from a prior
/// cache write within the 5-minute TTL.
export interface AnthropicUsage {
  inputTokens: number;
  cachedInputTokens: number;
  outputTokens: number;
}

/// Normalise the various shapes Anthropic returns into one struct.
/// Accepts a final message (`res.usage`) OR a raw usage object.
export function extractAnthropicUsage(payload: any): AnthropicUsage {
  const u = payload?.usage ?? payload ?? {};
  return {
    inputTokens: Number(u.input_tokens ?? 0),
    cachedInputTokens: Number(u.cache_read_input_tokens ?? 0),
    outputTokens: Number(u.output_tokens ?? 0),
  };
}

export function computeCost(
  model: string,
  inputTokens: number,
  cachedInputTokens: number,
  outputTokens: number,
): CostBreakdown {
  const p = pricingForModel(model);
  const costUsd =
    (inputTokens / 1_000_000) * p.inputPerM +
    (cachedInputTokens / 1_000_000) * p.cachedInputPerM +
    (outputTokens / 1_000_000) * p.outputPerM;
  // Weighted token count for quota — output costs 5x more than input on
  // Sonnet, so 1 output token = 5 charge-tokens. Cached input is dirt
  // cheap (10x cheaper than fresh input), so we count it at 0.2 weight.
  // Net effect: a typical 2000-in/500-out call charges ~4500 tokens
  // instead of 2500, matching the cost ratio more closely.
  const tokensCharged = Math.ceil(
    inputTokens + cachedInputTokens * 0.2 + outputTokens * 5,
  );
  return { costUsd, tokensCharged };
}
