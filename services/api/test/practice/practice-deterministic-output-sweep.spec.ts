import { fillOptionsWithSafeFallback } from '../../src/practice/engine/practice-engine.utils';

describe('practice deterministic output sweep helpers', () => {
  const badToken = /(__BAD_DUP___|_[0-9]+|Ω_|N_|V_|C_|J_|W_)/;

  it('numeric fallback options stay clean', () => {
    const out = fillOptionsWithSafeFallback(['8 Ω'], '8 Ω', 3);
    expect(out).toHaveLength(4);
    expect(new Set(out).size).toBe(4);
    for (const option of out) expect(option).not.toMatch(badToken);
  });

  it('text fallback options stay clean', () => {
    const out = fillOptionsWithSafeFallback(['Ampere'], 'Ampere', 5);
    expect(out).toHaveLength(4);
    expect(new Set(out).size).toBe(4);
    for (const option of out) expect(option).not.toMatch(badToken);
  });

  it('mixed unit fallback options stay clean', () => {
    const out = fillOptionsWithSafeFallback(['9 N'], '9 N', 1);
    expect(out).toHaveLength(4);
    expect(new Set(out).size).toBe(4);
    for (const option of out) expect(option).not.toMatch(badToken);
  });
});
