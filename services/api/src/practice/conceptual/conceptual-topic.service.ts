import { Injectable } from '@nestjs/common';
import { analyzeCustomPracticeTopic } from '../intake/custom-topic-intake';

export type ConceptualQuestionSeed = {
  stem: string;
  acceptedAnswers: string[];
  explanation: string;
};

export type ConceptualResolution = {
  ok: boolean;
  ready: boolean;
  subject: string;
  topic: string;
  confidence: number;
  needsClarification: boolean;
  gaps: string[];
  seeds: ConceptualQuestionSeed[];
  intake: ReturnType<typeof analyzeCustomPracticeTopic>;
};

@Injectable()
export class ConceptualTopicService {
  resolve(input: {
    subject?: unknown;
    topic?: unknown;
    topicLabel?: unknown;
    topicPathText?: unknown;
    questionCount?: number;
  }): ConceptualResolution {
    const intake = analyzeCustomPracticeTopic(input);
    const topic = String(intake.effectiveTopic || '').trim();
    const lower = topic.toLowerCase();
    const count = Math.max(1, Math.min(10, Number(input.questionCount ?? 3) || 3));

    const seeds: ConceptualQuestionSeed[] = [];
    const gaps: string[] = [];

    const broadOnly =
      intake.breadth === 'broad' &&
      !/\b(big o|music theory|conditional|conditionals|if statements|logic gates|sets|proof|algorithmic complexity)\b/i.test(lower);

    if (
      intake.topicType === 'conceptual' ||
      /\b(big o|music theory|conditional|conditionals|if statements|algorithmic complexity|time complexity|space complexity)\b/i.test(lower)
    ) {
      if (/big o|algorithmic complexity|time complexity|space complexity/i.test(lower)) {
        seeds.push(
          {
            stem: 'What does Big O notation describe in algorithms?',
            acceptedAnswers: [
              'How resource usage grows with input size',
              'How runtime or space grows with input size',
            ],
            explanation: 'Big O notation describes how runtime or space usage grows as input size increases.',
          },
          {
            stem: 'Why is O(n log n) generally considered more scalable than O(n^2)?',
            acceptedAnswers: [
              'Because it grows more slowly as n increases',
              'Its growth rate is smaller for large inputs',
            ],
            explanation: 'O(n log n) grows more slowly than O(n^2), so it scales better for large inputs.',
          },
          {
            stem: 'Does Big O usually describe exact runtime in seconds or growth behavior?',
            acceptedAnswers: ['Growth behavior', 'Asymptotic growth behavior'],
            explanation: 'Big O focuses on growth behavior, not exact runtime in seconds.',
          },
        );
      } else if (/music theory/i.test(lower)) {
        seeds.push(
          {
            stem: 'What is the role of a scale in music theory?',
            acceptedAnswers: [
              'An ordered set of notes used as a tonal framework',
              'A collection of notes that forms a tonal framework',
            ],
            explanation: 'A scale is an ordered collection of notes that provides a tonal framework.',
          },
          {
            stem: 'What does a chord usually represent in music theory?',
            acceptedAnswers: [
              'Multiple notes sounded together',
              'A group of notes played together',
            ],
            explanation: 'A chord is a group of notes sounded together.',
          },
          {
            stem: 'Why is rhythm an important part of music theory?',
            acceptedAnswers: [
              'It organizes timing and duration in music',
              'It controls timing patterns in music',
            ],
            explanation: 'Rhythm organizes timing and duration, shaping how music moves in time.',
          },
        );
      } else if (/conditional|conditionals|if statements/i.test(lower)) {
        seeds.push(
          {
            stem: 'What is the purpose of a conditional statement in programming?',
            acceptedAnswers: [
              'To make decisions based on whether a condition is true or false',
              'To choose actions based on a condition',
            ],
            explanation: 'Conditionals let a program choose different actions depending on whether a condition is true or false.',
          },
          {
            stem: 'What usually happens in an if-else structure?',
            acceptedAnswers: [
              'One branch runs when the condition is true and another when it is false',
              'Different branches run depending on the condition result',
            ],
            explanation: 'An if-else structure selects between branches based on the condition result.',
          },
          {
            stem: 'Why are conditionals useful in algorithms?',
            acceptedAnswers: [
              'They let logic adapt to different cases',
              'They let an algorithm respond to different inputs or situations',
            ],
            explanation: 'Conditionals allow algorithms to adapt their behavior to different cases and inputs.',
          },
        );
      } else {
        seeds.push({
          stem: `Which statement best captures the core idea of ${topic}?`,
          acceptedAnswers: [topic],
          explanation: `${topic} should be explained using its core idea, not random trivia.`,
        });
      }
    } else {
      gaps.push('no_conceptual_seed_path_yet');
    }

    const limitedSeeds = seeds.slice(0, count);
    const needsClarification = broadOnly || limitedSeeds.length === 0 || intake.needsClarification;

    if (broadOnly) gaps.push('broad_conceptual_topic');
    if (limitedSeeds.length === 0 && !gaps.includes('no_conceptual_seed_path_yet')) {
      gaps.push('no_conceptual_seed_path_yet');
    }

    return {
      ok: limitedSeeds.length > 0,
      ready: limitedSeeds.length > 0 && !broadOnly,
      subject: intake.effectiveSubject,
      topic: intake.effectiveTopic,
      confidence: limitedSeeds.length > 0 ? 0.72 : 0.0,
      needsClarification,
      gaps,
      seeds: limitedSeeds,
      intake,
    };
  }
}
