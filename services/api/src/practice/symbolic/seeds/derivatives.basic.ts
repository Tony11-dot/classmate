import type { SymbolicQuestionSeed } from '../symbolic-topic.service';

export const DERIVATIVE_BASIC_SEEDS: SymbolicQuestionSeed[] = [
  {
    stem: 'What is the derivative of $x^{2}$ ?',
    options: ['$2x$', '$x$', '$x^{3}$', '2'],
    correctIndex: 0,
    explanation: 'Using the power rule, $\\frac{d}{dx}(x^{2}) = 2x$.',
    recommendedTimeSeconds: 35,
  },
  {
    stem: 'What is the derivative of $3x^{3}$ ?',
    options: ['$9x^{2}$', '$3x^{2}$', '$6x$', '$x^{3}$'],
    correctIndex: 0,
    explanation: 'Using the power rule, $\\frac{d}{dx}(3x^{3}) = 9x^{2}$.',
    recommendedTimeSeconds: 40,
  },
  {
    stem: 'What is the derivative of a constant?',
    options: ['0', '1', 'The constant itself', 'Undefined'],
    correctIndex: 0,
    explanation: 'The derivative of any constant is 0.',
    recommendedTimeSeconds: 25,
  },
  {
    stem: 'What is the derivative of $x^{3}$ ?',
    options: ['$3x^{2}$', '$x^{2}$', '$3x$', '$x^{4}$'],
    correctIndex: 0,
    explanation: 'Using the power rule, $\\frac{d}{dx}(x^{3}) = 3x^{2}$.',
    recommendedTimeSeconds: 35,
  },
  {
    stem: 'What is the derivative of $5x$ ?',
    options: ['5', '$x$', '$5x$', '0'],
    correctIndex: 0,
    explanation: 'The derivative of $ax$ is $a$.',
    recommendedTimeSeconds: 25,
  },
];
