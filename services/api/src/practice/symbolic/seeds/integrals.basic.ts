import type { SymbolicQuestionSeed } from '../symbolic-topic.service';

export const INTEGRALS_BASIC_SEEDS: SymbolicQuestionSeed[] = [
  {
    stem: 'What is ∫ x dx ?',
    options: ['x^2/2 + C', '1', 'x + C', '2x + C'],
    correctIndex: 0,
    explanation: 'Using the power rule for integrals, ∫x dx = x^2/2 + C.',
    recommendedTimeSeconds: 35,
  },
  {
    stem: 'What is ∫ 1 dx ?',
    options: ['x + C', '1 + C', '0', 'x^2 + C'],
    correctIndex: 0,
    explanation: 'The antiderivative of 1 is x + C.',
    recommendedTimeSeconds: 25,
  },
  {
    stem: 'What is ∫ 3x^2 dx ?',
    options: ['x^3 + C', '3x + C', '6x + C', 'x^2 + C'],
    correctIndex: 0,
    explanation: 'Since d/dx(x^3)=3x^2, the antiderivative is x^3 + C.',
    recommendedTimeSeconds: 35,
  },
  {
    stem: 'Why do indefinite integrals include + C?',
    options: [
      'Because many functions differ by a constant but have the same derivative',
      'Because the answer is always approximate',
      'Because integration removes variables',
      'Because only constants can be integrated',
    ],
    correctIndex: 0,
    explanation: 'Different constants vanish when differentiated, so +C is required.',
    recommendedTimeSeconds: 30,
  },
  {
    stem: 'What is ∫ 5 dx ?',
    options: ['5x + C', 'x^5 + C', '5 + C', '0'],
    correctIndex: 0,
    explanation: 'The antiderivative of a constant k is kx + C.',
    recommendedTimeSeconds: 25,
  },
];
