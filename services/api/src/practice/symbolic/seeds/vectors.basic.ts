import type { SymbolicQuestionSeed } from '../symbolic-topic.service';

export const VECTORS_BASIC_SEEDS: SymbolicQuestionSeed[] = [
  {
    stem: 'A vector has which two main features?',
    options: ['Magnitude and direction', 'Area and volume', 'Mass and charge', 'Slope and intercept'],
    correctIndex: 0,
    explanation: 'Vectors are quantities defined by magnitude and direction.',
    recommendedTimeSeconds: 25,
  },
  {
    stem: 'What is the magnitude of the vector (3,4)?',
    options: ['5', '7', '12', '1'],
    correctIndex: 0,
    explanation: 'Magnitude = √(3^2 + 4^2) = √25 = 5.',
    recommendedTimeSeconds: 35,
  },
  {
    stem: 'What is (2,1) + (3,4)?',
    options: ['(5,5)', '(6,4)', '(1,3)', '(5,4)'],
    correctIndex: 0,
    explanation: 'Add vectors component-wise: (2+3, 1+4) = (5,5).',
    recommendedTimeSeconds: 30,
  },
  {
    stem: 'What is 2·(1,3)?',
    options: ['(2,6)', '(3,9)', '(2,3)', '(1,6)'],
    correctIndex: 0,
    explanation: 'Scalar multiplication doubles each component.',
    recommendedTimeSeconds: 25,
  },
];
