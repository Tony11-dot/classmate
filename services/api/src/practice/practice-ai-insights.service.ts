import { Injectable } from '@nestjs/common';
import { getOpenAIClient } from '../tutor/providers/openai.provider';

type PracticeProgressTopicDto = {
  subject: string;
  topicLabel: string;
  accuracy: number;
  totalAnswered: number;
};

type PracticeProgressSummaryDto = {
  userId: string;
  totalSessions: number;
  totalAttempts: number;
  totalCorrect: number;
  overallAccuracy: number;
  weakTopics: PracticeProgressTopicDto[];
  strongestTopics: PracticeProgressTopicDto[];
};

type AiInsightTone = 'focus' | 'strength' | 'next_step' | 'baseline';

type AiInsightCard = {
  title: string;
  body: string;
  tone: AiInsightTone;
};

type AiInsightsSummaryDto = {
  ok: true;
  source: 'llm' | 'deterministic';
  headline: string;
  summary: string;
  cards: AiInsightCard[];
  suggestedPrompt: string;
};

@Injectable()
export class PracticeAiInsightsService {
  private accuracyPct(value: number): number {
    const n = Number(value ?? 0);
    return Math.max(0, Math.min(100, Math.round(n * 100)));
  }

  private safeTopic(topic?: PracticeProgressTopicDto | null): PracticeProgressTopicDto | null {
    if (!topic) return null;
    return {
      subject: String(topic.subject ?? '').trim(),
      topicLabel: String(topic.topicLabel ?? '').trim(),
      accuracy: Number(topic.accuracy ?? 0),
      totalAnswered: Number(topic.totalAnswered ?? 0),
    };
  }

  private buildDeterministic(summary: PracticeProgressSummaryDto): AiInsightsSummaryDto {
    const accuracy = this.accuracyPct(summary.overallAccuracy);
    const weak = this.safeTopic(summary.weakTopics?.[0]);
    const strong = this.safeTopic(summary.strongestTopics?.[0]);

    const headline =
      summary.totalAttempts <= 0
        ? 'Start building your practice profile'
        : weak
          ? `Focus on ${weak.topicLabel} next`
          : strong
            ? `You are doing well in ${strong.topicLabel}`
            : 'Your practice profile is loading in';

    const cards: AiInsightCard[] = [];

    if (summary.totalAttempts <= 0) {
      cards.push({
        title: 'No practice signal yet',
        body: 'Complete a few practice sessions so ClassMate can build grounded insight cards for you.',
        tone: 'baseline',
      });
    } else {
      cards.push({
        title: 'Current level',
        body: `You answered ${summary.totalAttempts} practice questions across ${summary.totalSessions} sessions with ${accuracy}% accuracy.`,
        tone: 'baseline',
      });

      if (weak) {
        cards.push({
          title: `Weak area: ${weak.topicLabel}`,
          body: `${weak.subject} is asking for more reps here. Your current accuracy is ${this.accuracyPct(
            weak.accuracy,
          )}% over ${weak.totalAnswered} questions.`,
          tone: 'focus',
        });
      }

      if (strong) {
        cards.push({
          title: `Strong area: ${strong.topicLabel}`,
          body: `This is one of your better signals right now: ${this.accuracyPct(
            strong.accuracy,
          )}% accuracy over ${strong.totalAnswered} questions.`,
          tone: 'strength',
        });
      }

      cards.push({
        title: 'Best next move',
        body: weak
          ? `Run one short targeted ${weak.subject} session focused on ${weak.topicLabel}, then come back and compare the signal.`
          : strong
            ? `Keep momentum by increasing challenge in ${strong.topicLabel} or switching to a nearby topic.`
            : 'Keep practicing consistently so the insights layer can identify stable strengths and weaknesses.',
        tone: 'next_step',
      });
    }

    return {
      ok: true,
      source: 'deterministic',
      headline,
      summary:
        summary.totalAttempts <= 0
          ? 'There is not enough practice data yet for a rich AI summary.'
          : weak
            ? `Your main opportunity right now is ${weak.topicLabel}. The fastest win is focused repetition on that topic.`
            : strong
              ? `Your practice data looks healthiest in ${strong.topicLabel}. Keep momentum while gradually increasing difficulty.`
              : 'Keep practicing to unlock more detailed AI insight.',
      cards: cards.slice(0, 3),
      suggestedPrompt: weak
        ? `Help me improve in ${weak.subject} ${weak.topicLabel} step by step at Bagrut level.`
        : strong
          ? `Give me a harder Bagrut-level challenge in ${strong.subject} ${strong.topicLabel}.`
          : 'Help me choose the best next practice topic based on my current level.',
    };
  }

  private parseJsonObject(raw: string): any | null {
    const text = String(raw ?? '').trim();
    if (!text) return null;

    try {
      return JSON.parse(text);
    } catch {}

    const first = text.indexOf('{');
    const last = text.lastIndexOf('}');
    if (first >= 0 && last > first) {
      const slice = text.slice(first, last + 1);
      try {
        return JSON.parse(slice);
      } catch {}
    }

    return null;
  }

  private sanitizeModelOutput(input: any, fallback: AiInsightsSummaryDto): AiInsightsSummaryDto {
    const headline = String(input?.headline ?? fallback.headline).trim() || fallback.headline;
    const summary = String(input?.summary ?? fallback.summary).trim() || fallback.summary;
    const suggestedPrompt =
      String(input?.suggestedPrompt ?? fallback.suggestedPrompt).trim() || fallback.suggestedPrompt;

    const allowedTones = new Set(['focus', 'strength', 'next_step', 'baseline']);
    const cardsRaw = Array.isArray(input?.cards) ? input.cards : [];
    const cards = cardsRaw
      .map((card: any) => ({
        title: String(card?.title ?? '').trim(),
        body: String(card?.body ?? '').trim(),
        tone: String(card?.tone ?? 'baseline').trim(),
      }))
      .filter((card: any) => card.title && card.body)
      .slice(0, 3)
      .map((card: any) => ({
        title: card.title,
        body: card.body,
        tone: (allowedTones.has(card.tone) ? card.tone : 'baseline') as AiInsightTone,
      }));

    return {
      ok: true,
      source: 'llm',
      headline,
      summary,
      cards: cards.length ? cards : fallback.cards,
      suggestedPrompt,
    };
  }

  async generate(summary: PracticeProgressSummaryDto): Promise<AiInsightsSummaryDto> {
    const fallback = this.buildDeterministic(summary);

    if (summary.totalAttempts <= 0) {
      return fallback;
    }

    try {
      const client = getOpenAIClient();
      const model = process.env.OPENAI_MODEL || 'gpt-4.1-mini';

      const weak = this.safeTopic(summary.weakTopics?.[0]);
      const strong = this.safeTopic(summary.strongestTopics?.[0]);

      const prompt = [
        'You are NOVA, the ClassMate AI study coach.',
        'Return strict JSON only. No markdown. No code fences.',
        'Never invent trend claims, time-based claims, or data that is not present.',
        'Keep the tone supportive, concise, Bagrut-level, and student-facing.',
        'Ground every sentence in the provided stats only.',
        '',
        'Required JSON shape:',
        '{"headline":"...","summary":"...","cards":[{"title":"...","body":"...","tone":"focus|strength|next_step|baseline"}],"suggestedPrompt":"..."}',
        '',
        'Available stats:',
        JSON.stringify(
          {
            totalSessions: summary.totalSessions,
            totalAttempts: summary.totalAttempts,
            totalCorrect: summary.totalCorrect,
            overallAccuracyPct: this.accuracyPct(summary.overallAccuracy),
            weakestTopic: weak
              ? {
                  subject: weak.subject,
                  topicLabel: weak.topicLabel,
                  accuracyPct: this.accuracyPct(weak.accuracy),
                  totalAnswered: weak.totalAnswered,
                }
              : null,
            strongestTopic: strong
              ? {
                  subject: strong.subject,
                  topicLabel: strong.topicLabel,
                  accuracyPct: this.accuracyPct(strong.accuracy),
                  totalAnswered: strong.totalAnswered,
                }
              : null,
          },
          null,
          2,
        ),
        '',
        'Rules:',
        '- headline: max 10 words',
        '- summary: max 2 sentences',
        '- exactly 3 cards',
        '- card titles: max 6 words',
        '- card bodies: max 2 sentences each',
        '- suggestedPrompt: a concrete prompt the student can send to NOVA next',
      ].join('\n');

      const res = await client.chat.completions.create({
        model,
        temperature: 0.3,
        messages: [
          { role: 'system', content: 'You output strict JSON only.' },
          { role: 'user', content: prompt },
        ],
      });

      const text = String(res.choices?.[0]?.message?.content ?? '').trim();
      const parsed = this.parseJsonObject(text);
      if (!parsed) return fallback;

      return this.sanitizeModelOutput(parsed, fallback);
    } catch {
      return fallback;
    }
  }
}
