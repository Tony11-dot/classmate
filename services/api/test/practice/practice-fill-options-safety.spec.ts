import { fillOptionsWithSafeFallback } from '../../src/practice/engine/practice-engine.utils';

describe('fillOptionsWithSafeFallback', () => {
  it('fills numeric answers with clean numeric distractors', () => {
    const out = fillOptionsWithSafeFallback(['8 Ω'], '8 Ω', 3);
    expect(out).toHaveLength(4);
    expect(new Set(out).size).toBe(4);
    expect(out).toContain('8 Ω');
    expect(out.some((x) => x.includes('__BAD_DUP___'))).toBe(false);
    expect(out.some((x) => /_[0-9]+/.test(x))).toBe(false);
  });

  it('fills text answers with safe textual distractors', () => {
    const out = fillOptionsWithSafeFallback(['Coulomb'], 'Coulomb', 7);
    expect(out).toHaveLength(4);
    expect(new Set(out).size).toBe(4);
    expect(out).toContain('Coulomb');
    expect(out.some((x) => x.includes('__BAD_DUP___'))).toBe(false);
  });

  it('does not duplicate the correct answer', () => {
    const out = fillOptionsWithSafeFallback(['9 N', '12 N'], '9 N', 1);
    expect(out).toHaveLength(4);
    expect(out.filter((x) => x === '9 N')).toHaveLength(1);
  });
});
