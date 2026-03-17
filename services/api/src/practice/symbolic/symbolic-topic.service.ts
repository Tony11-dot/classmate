import { Injectable } from '@nestjs/common';
import { analyzeCustomPracticeTopic } from '../intake/custom-topic-intake';

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
    const seeds: SymbolicQuestionSeed[] = [];
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

    if (/derivative|derivatives/i.test(lower)) {
      seeds.push(
        {
          stem: 'What is the derivative of x^2 ?',
          options: ['2x', 'x', 'x^3', '2'],
          correctIndex: 0,
          explanation: 'Using the power rule, d/dx(x^2) = 2x.',
          recommendedTimeSeconds: 35,
        },
        {
          stem: 'What is the derivative of 3x^3 ?',
          options: ['9x^2', '3x^2', '6x', 'x^3'],
          correctIndex: 0,
          explanation: 'Using the power rule, d/dx(3x^3) = 9x^2.',
          recommendedTimeSeconds: 40,
        },
        {
          stem: 'What is the derivative of a constant?',
          options: ['0', '1', 'The constant itself', 'Undefined'],
          correctIndex: 0,
          explanation: 'The derivative of any constant is 0.',
          recommendedTimeSeconds: 25,
        },
      );
    } else if (/limit|limits/i.test(lower)) {
      seeds.push(
        {
          stem: 'What is lim(x→2) (x + 3) ?',
          options: ['5', '3', '2', '1'],
          correctIndex: 0,
          explanation: 'For a continuous expression like x + 3, substitute x = 2 to get 5.',
          recommendedTimeSeconds: 30,
        },
        {
          stem: 'What is lim(x→1) (x^2) ?',
          options: ['1', '2', '0', 'Undefined'],
          correctIndex: 0,
          explanation: 'For a polynomial, direct substitution works. 1^2 = 1.',
          recommendedTimeSeconds: 30,
        },
        {
          stem: 'When a function is continuous at x = a, how do you evaluate its limit there?',
          options: [
            'Substitute x = a directly',
            'Always use L’Hôpital’s rule',
            'The limit does not exist',
            'Differentiate first',
          ],
          correctIndex: 0,
          explanation: 'For continuous functions, the limit at a point equals the function value there.',
          recommendedTimeSeconds: 35,
        },
      );
    } else if (/matrix|matrices/i.test(lower)) {
      seeds.push(
        {
          stem: 'If A and B are 2×2 matrices, what is the size of A + B ?',
          options: ['2×2', '4×4', '2×1', 'Undefined always'],
          correctIndex: 0,
          explanation: 'Matrices can be added only when they have the same dimensions, and the result keeps that size.',
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
          explanation: 'Matrix addition is defined only when both matrices have the same dimensions.',
          recommendedTimeSeconds: 35,
        },
        {
          stem: 'If a matrix has 3 rows and 2 columns, what is its size?',
          options: ['3×2', '2×3', '5×5', '6×1'],
          correctIndex: 0,
          explanation: 'Matrix size is written as rows × columns.',
          recommendedTimeSeconds: 25,
        },
      );
    } else if (/integral|integrals/i.test(lower)) {
      seeds.push(
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
          explanation: 'Different constants vanish under differentiation, so indefinite integrals include +C.',
          recommendedTimeSeconds: 35,
        },
        {
          stem: 'What is ∫ 1 dx ?',
          options: ['x + C', '1 + C', '0', 'ln(x) + C'],
          correctIndex: 0,
          explanation: 'The antiderivative of 1 is x + C.',
          recommendedTimeSeconds: 25,
        },
      );
    } else {
      gaps.push('symbolic_generation_not_ready');
    }

    const limited = seeds.slice(0, count);
    const ready = limited.length > 0;
    const needsClarification = !ready;

    if (!ready && gaps.length === 0) gaps.push('symbolic_generation_not_ready');
    if (!ready && !gaps.includes('symbolic_generation_not_ready')) gaps.push('symbolic_generation_not_ready');

    return {
      ok: ready,
      ready,
      subject: intake.effectiveSubject,
      topic: intake.effectiveTopic,
      confidence: ready ? 0.8 : 0,
      needsClarification,
      gaps,
      seeds: limited,
      intake,
    };
  }
}
