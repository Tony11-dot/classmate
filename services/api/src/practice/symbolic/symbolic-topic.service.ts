import { Injectable } from '@nestjs/common';
import { analyzeCustomPracticeTopic } from '../intake/custom-topic-intake';
import { DERIVATIVE_BASIC_SEEDS } from './seeds/derivatives.basic';
import { LIMIT_BASIC_SEEDS } from './seeds/limits.basic';
import { INTEGRALS_BASIC_SEEDS } from './seeds/integrals.basic';
import { VECTORS_BASIC_SEEDS } from './seeds/vectors.basic';

export type SymbolicQuestionSeed = {
  stem: string;
  options: string[];
  correctIndex: number;
  explanation: string;
  recommendedTimeSeconds?: number;
};

export type SymbolicResolution = {
  ok: boolean;
  ready: boolean;
  subject: string;
  topic: string;
  confidence: number;
  needsClarification: boolean;
  gaps: string[];
  seeds: SymbolicQuestionSeed[];
  intake: ReturnType<typeof analyzeCustomPracticeTopic>;
};

function isLikelySymbolicTopicText(topic: string): boolean {
  const t = String(topic ?? '').trim().toLowerCase();

  const explicit =
    /\b(derivative|derivatives|partial derivative|partial derivatives|limit|limits|integral|integrals|matrix|matrices|matrix multiplication|vector|vectors|eigenvalue|eigenvalues|eigenvector|eigenvectors|determinant|determinants|gradient|gradients|jacobian|jacobians|taylor series|maclaurin series|sequence and series|series expansion|differential equation|differential equations|laplace transform|laplace transforms|fourier series|fourier transform|complex number|complex numbers|complex analysis|linear algebra)\b/.test(t);

  const symbolicStyle =
    /[=^+\-*/()]/.test(topic) ||
    /\b(solve|simplify|differentiate|integrate|factor|expand|evaluate|compute|calculate|prove)\b/.test(t);

  return explicit || symbolicStyle;
}

function isBasicSymbolicSeedTopic(topic: string): boolean {
  const tokens = String(topic ?? '')
    .trim()
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, ' ')
    .split(/\s+/)
    .filter(Boolean)
    .filter(
      (token) =>
        ![
          'a',
          'an',
          'and',
          'by',
          'for',
          'in',
          'of',
          'on',
          'the',
          'to',
          'with',
          'math',
          'mathematics',
          'calculus',
          'algebra',
          'basic',
          'basics',
          'intro',
          'introduction',
          'overview',
          'practice',
          'review',
          'foundation',
          'foundations',
          'beginner',
          'beginners',
          'elementary',
        ].includes(token),
    );

  return tokens.length <= 2;
}

@Injectable()
export class SymbolicTopicService {
  resolve(input: {
    subject?: unknown;
    topic?: unknown;
    topicLabel?: unknown;
    topicPathText?: unknown;
    questionCount?: number;
    difficulty?: unknown;
  }): SymbolicResolution {
    const intake = analyzeCustomPracticeTopic(input);
    const topic = String(intake.effectiveTopic || '').trim();
    const lower = topic.toLowerCase();
    const count = Math.max(1, Math.min(10, Number(input.questionCount ?? 3) || 3));
    const gaps: string[] = [];

    const isSymbolicCandidate =
      intake.generationStrategy === 'symbolic' ||
      intake.topicType === 'symbolic' ||
      isLikelySymbolicTopicText(topic);

    if (!isSymbolicCandidate) {
      gaps.push('not_symbolic');
      return {
        ok: false,
        ready: false,
        subject: intake.effectiveSubject,
        topic: intake.effectiveTopic,
        confidence: 0,
        needsClarification: false,
        gaps,
        seeds: [],
        intake,
      };
    }

    if (/derivative|derivatives/i.test(lower) && isBasicSymbolicSeedTopic(topic)) {
      return {
        ok: true,
        ready: true,
        subject: intake.effectiveSubject,
        topic: intake.effectiveTopic,
        confidence: 0.8,
        needsClarification: false,
        gaps: [],
        seeds: DERIVATIVE_BASIC_SEEDS.slice(0, count),
        intake,
      };
    }

    if (/limit|limits/i.test(lower) && isBasicSymbolicSeedTopic(topic)) {
      return {
        ok: true,
        ready: true,
        subject: intake.effectiveSubject,
        topic: intake.effectiveTopic,
        confidence: 0.8,
        needsClarification: false,
        gaps: [],
        seeds: LIMIT_BASIC_SEEDS.slice(0, count),
        intake,
      };
    }

    if (/matrix|matrices/i.test(lower) && isBasicSymbolicSeedTopic(topic)) {
      const seeds: SymbolicQuestionSeed[] = [
        {
          stem: 'If A and B are 2×2 matrices, what is the size of A + B ?',
          options: ['2×2', '4×4', '2×1', 'Undefined always'],
          correctIndex: 0,
          explanation:
            'Matrices can be added only when they have the same dimensions, and the result keeps that size.',
          recommendedTimeSeconds: 35,
        },
        {
          stem: 'What condition is required to add two matrices?',
          options: [
            'They must have the same dimensions',
            'They must both be square only',
            'They must have determinant 1',
            'They must have the same entries',
          ],
          correctIndex: 0,
          explanation:
            'Matrix addition is defined only when both matrices have the same dimensions.',
          recommendedTimeSeconds: 35,
        },
        {
          stem: 'If a matrix has 3 rows and 2 columns, what is its size?',
          options: ['3×2', '2×3', '5×5', '6×1'],
          correctIndex: 0,
          explanation: 'Matrix size is written as rows × columns.',
          recommendedTimeSeconds: 25,
        },
      ];

      return {
        ok: true,
        ready: true,
        subject: intake.effectiveSubject,
        topic: intake.effectiveTopic,
        confidence: 0.8,
        needsClarification: false,
        gaps: [],
        seeds: seeds.slice(0, count),
        intake,
      };
    }

    if (/integral|integrals/i.test(lower) && isBasicSymbolicSeedTopic(topic)) {
      const seeds: SymbolicQuestionSeed[] = [
        {
          stem: 'What is ∫ x dx ?',
          options: ['x^2/2 + C', 'x + C', '2x + C', '1/x + C'],
          correctIndex: 0,
          explanation: 'Using the reverse power rule, ∫ x dx = x^2/2 + C.',
          recommendedTimeSeconds: 40,
        },
        {
          stem: 'Why is +C included in an indefinite integral?',
          options: [
            'Because derivatives of constants are zero',
            'Because every integral equals zero at x=0',
            'Because integrals must be normalized',
            'Because constants cannot appear in functions',
          ],
          correctIndex: 0,
          explanation:
            'Different constants vanish under differentiation, so indefinite integrals include +C.',
          recommendedTimeSeconds: 35,
        },
        {
          stem: 'What is ∫ 1 dx ?',
          options: ['x + C', '1 + C', '0', 'ln(x) + C'],
          correctIndex: 0,
          explanation: 'The antiderivative of 1 is x + C.',
          recommendedTimeSeconds: 25,
        },
      ];

      return {
        ok: true,
        ready: true,
        subject: intake.effectiveSubject,
        topic: intake.effectiveTopic,
        confidence: 0.8,
        needsClarification: false,
        gaps: [],
        seeds: seeds.slice(0, count),
        intake,
      };
    }

    gaps.push('symbolic_generation_not_ready');

    return {
      ok: false,
      ready: false,
      subject: intake.effectiveSubject,
      topic: intake.effectiveTopic,
      confidence: 0,
      needsClarification: true,
      gaps,
      seeds: [],
      intake,
    };
  }
}
