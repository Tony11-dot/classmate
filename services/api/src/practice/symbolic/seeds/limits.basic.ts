import type { SymbolicQuestionSeed } from '../symbolic-topic.service';

export const LIMIT_BASIC_SEEDS: SymbolicQuestionSeed[] = [
  {
    stem: 'What is $\\lim_{x\\to 2} (x + 3)$ ?',
    options: ['5', '3', '2', '1'],
    correctIndex: 0,
    explanation: 'For a continuous expression like $x + 3$, substitute $x = 2$ to get 5.',
    recommendedTimeSeconds: 30,
  },
  {
    stem: 'What is $\\lim_{x\\to 1} (x^{2})$ ?',
    options: ['1', '2', '0', 'Undefined'],
    correctIndex: 0,
    explanation: 'For a polynomial, direct substitution works. $1^{2} = 1$.',
    recommendedTimeSeconds: 30,
  },
  {
    stem: 'When a function is continuous at x = a, how do you evaluate its limit there?',
    options: [
      'Substitute $x = a$ directly',
      'Always use L’Hôpital’s rule',
      'The limit does not exist',
      'Differentiate first',
    ],
    correctIndex: 0,
    explanation: 'For continuous functions, the limit at a point equals the function value there.',
    recommendedTimeSeconds: 35,
  },
  {
    stem: 'What is $\\lim_{x\\to\\infty} \\frac{1}{x}$ ?',
    options: ['0', '1', '$\\infty$', 'Does not exist'],
    correctIndex: 0,
    explanation: 'As $x$ grows without bound, $\\frac{1}{x}$ gets closer and closer to 0.',
    recommendedTimeSeconds: 30,
  },
  {
    stem: 'What is $\\lim_{x\\to 3} (2x - 1)$ ?',
    options: ['5', '6', '3', '1'],
    correctIndex: 0,
    explanation: 'For a continuous linear expression, substitute $x = 3$ to get $2\\cdot 3 - 1 = 5$.',
    recommendedTimeSeconds: 25,
  },
];
