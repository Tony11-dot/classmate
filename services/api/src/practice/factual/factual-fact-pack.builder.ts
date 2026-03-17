import { Injectable } from '@nestjs/common';
import {
  analyzeCustomPracticeTopic,
  type CustomTopicIntakeResult,
} from '../intake/custom-topic-intake';
import type { FactualEvidenceItem } from './factual-quiz.types';

export type FactualFactPack = {
  topic: string;
  subject: string;
  facts: string[];
  evidence: FactualEvidenceItem[];
  gaps: string[];
  needsClarification: boolean;
  intake: CustomTopicIntakeResult;
};

@Injectable()
export class FactualFactPackBuilder {
  build(input: {
    intake?: CustomTopicIntakeResult;
    subject?: unknown;
    topic?: unknown;
    topicLabel?: unknown;
    topicPathText?: unknown;
  }): FactualFactPack {
    const intake =
      input.intake ??
      analyzeCustomPracticeTopic({
        subject: input.subject,
        topic: input.topic,
        topicLabel: input.topicLabel,
        topicPathText: input.topicPathText,
      });

    const topic = String(
      input.topic ?? input.topicLabel ?? intake.effectiveTopic ?? '',
    ).trim();
    const lower = topic.toLowerCase();

    const facts: string[] = [];
    const evidence: FactualEvidenceItem[] = [];
    const gaps: string[] = [];

    if (lower.includes('tennis history')) {
      facts.push(
        'Modern lawn tennis developed in the nineteenth century from earlier racket-and-ball games.',
        'The four Grand Slam tournaments are the Australian Open, Roland-Garros, Wimbledon, and the US Open.',
        'The Open Era began in 1968, allowing professionals to compete in the major championships.',
      );
      evidence.push(
        {
          sourceId: 'sports:tennis_history:origins',
          title: 'Tennis history origins',
          snippet:
            'Modern lawn tennis developed from earlier racket-and-ball games.',
        },
        {
          sourceId: 'sports:tennis_history:grand_slams',
          title: 'Grand Slam tournaments',
          snippet:
            'The four Grand Slam tournaments are the Australian Open, Roland-Garros, Wimbledon, and the US Open.',
        },
        {
          sourceId: 'sports:tennis_history:open_era',
          title: 'Open Era',
          snippet:
            'The Open Era began in 1968, allowing professionals to compete in the major championships.',
        },
      );
    } else if (
      lower.includes('world war 2') ||
      lower.includes('world war ii')
    ) {
      facts.push(
        'World War II lasted from 1939 to 1945.',
        'The war involved major Allied and Axis powers across multiple theaters.',
        'The war ended in 1945 after the defeat of Nazi Germany and Imperial Japan.',
      );
      evidence.push(
        {
          sourceId: 'history:ww2:dates',
          title: 'World War II dates',
          snippet: 'World War II lasted from 1939 to 1945.',
        },
        {
          sourceId: 'history:ww2:sides',
          title: 'World War II major powers',
          snippet:
            'The war involved major Allied and Axis powers across multiple theaters.',
        },
        {
          sourceId: 'history:ww2:end',
          title: 'World War II end',
          snippet:
            'The war ended in 1945 after the defeat of Nazi Germany and Imperial Japan.',
        },
      );
    } else if (/\b(world capitals|capital cities|capitals)\b/.test(lower)) {
      facts.push(
        'Paris is the capital of France.',
        'Tokyo is the capital of Japan.',
        'Cairo is the capital of Egypt.',
      );
      evidence.push(
        {
          sourceId: 'gk:world_capitals:paris',
          title: 'Paris',
          snippet: 'Paris is the capital of France.',
        },
        {
          sourceId: 'gk:world_capitals:tokyo',
          title: 'Tokyo',
          snippet: 'Tokyo is the capital of Japan.',
        },
        {
          sourceId: 'gk:world_capitals:cairo',
          title: 'Cairo',
          snippet: 'Cairo is the capital of Egypt.',
        },
      );
    } else if (/\bflags\b/.test(lower)) {
      facts.push(
        'Japan has a white flag with a red circle.',
        'Canada has a red maple leaf on its flag.',
        'Brazil has a green flag with a yellow diamond.',
      );
      evidence.push(
        {
          sourceId: 'gk:flags:japan',
          title: 'Japan flag',
          snippet: 'White flag with a red circle.',
        },
        {
          sourceId: 'gk:flags:canada',
          title: 'Canada flag',
          snippet: 'Red maple leaf.',
        },
        {
          sourceId: 'gk:flags:brazil',
          title: 'Brazil flag',
          snippet: 'Green with yellow diamond.',
        },
      );
    } else if (/\bcountries\b/.test(lower)) {
      facts.push(
        'Brazil is in South America.',
        'Nigeria is in Africa.',
        'Canada is in North America.',
      );
      evidence.push(
        {
          sourceId: 'gk:countries:brazil',
          title: 'Brazil',
          snippet: 'Brazil is in South America.',
        },
        {
          sourceId: 'gk:countries:nigeria',
          title: 'Nigeria',
          snippet: 'Nigeria is in Africa.',
        },
        {
          sourceId: 'gk:countries:canada',
          title: 'Canada',
          snippet: 'Canada is in North America.',
        },
      );
    } else if (/\bplanets\b/.test(lower)) {
      facts.push(
        'Mercury is the closest planet to the Sun.',
        'Earth is the third planet from the Sun.',
        'Jupiter is the largest planet in the Solar System.',
      );
      evidence.push(
        {
          sourceId: 'gk:planets:mercury',
          title: 'Mercury',
          snippet: 'Mercury is the closest planet to the Sun.',
        },
        {
          sourceId: 'gk:planets:earth',
          title: 'Earth',
          snippet: 'Earth is the third planet from the Sun.',
        },
        {
          sourceId: 'gk:planets:jupiter',
          title: 'Jupiter',
          snippet: 'Jupiter is the largest planet in the Solar System.',
        },
      );
    } else {
      gaps.push('no_domain_fact_pack_yet');
    }

    const needsClarification = gaps.length > 0 || facts.length < 3;

    return {
      topic: intake.effectiveTopic,
      subject: intake.effectiveSubject,
      facts,
      evidence,
      gaps,
      needsClarification,
      intake,
    };
  }
}
