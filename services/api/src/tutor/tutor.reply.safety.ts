export function basicTutorSafetyCheck(content: string) {
  const text = String(content ?? '');
  const low = text.toLowerCase();

  // Hard contract markers
  const okBagrut = low.includes('bagrut');
  const okQuiz = low.includes('mini-quiz');

  // Very rough "too advanced" / out-of-scope heuristics
  const looksUniversity =
    low.includes('epsilon') ||
    low.includes('delta-epsilon') ||
    low.includes('measure theory') ||
    low.includes('laplace transform') ||
    low.includes('fourier transform') ||
    low.includes('lagrangian') ||
    low.includes('schrodinger') ||
    low.includes('tensor') ||
    low.includes('riemann') ||
    low.includes('manifold');

  // High-risk topics (keep simple)
  const looksMedical = low.includes('diagnos') || low.includes('treatment') || low.includes('dose');
  const looksLegal = low.includes('lawsuit') || low.includes('contract law') || low.includes('criminal');

  return {
    ok: okBagrut && okQuiz && !looksUniversity && !looksMedical && !looksLegal,
    reasons: {
      okBagrut,
      okQuiz,
      looksUniversity,
      looksMedical,
      looksLegal,
    },
  };
}
