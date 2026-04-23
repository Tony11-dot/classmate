import { Injectable, NotFoundException } from '@nestjs/common';

type FormQuestionType =
  | 'shortAnswer'
  | 'paragraph'
  | 'multipleChoice'
  | 'checkboxes'
  | 'dropdown'
  | 'linearScale';

type FormQuestion = {
  id: string;
  title: string;
  description?: string;
  type: FormQuestionType;
  required?: boolean;
  options?: string[];
  minScale?: number;
  maxScale?: number;
  stats?: {
    choiceStats?: Array<{ label: string; count: number; fraction: number }>;
    textSamples?: string[];
    averageScale?: number;
  };
};

type PublishedForm = {
  id: string;
  subject: string;
  title: string;
  description: string;
  teacher: string;
  audienceLabel: string;
  acceptingResponses: boolean;
  allowMultipleResponses: boolean;
  published: boolean;
  summary: {
    responsesCount: number;
    pendingCount: number;
    completionRate: number;
    averageDurationLabel: string;
    publishedLabel: string;
  };
  questions: FormQuestion[];
};

@Injectable()
export class FormsService {
  live(user: any) {
    return { ok: true, items: this.visibleForms(user) };
  }

  byId(user: any, id: string) {
    const form = this.visibleForms(user).find((item) => item.id === id);
    if (!form) {
      throw new NotFoundException('Form not found');
    }
    return { ok: true, form };
  }

  private visibleForms(user: any): PublishedForm[] {
    const roles = new Set<string>((user?.roles ?? []).map((role: any) => `${role}`.toUpperCase()));
    const teacherLike = roles.has('TEACHER') || roles.has('ADMIN');
    const audience = teacherLike ? 'School-wide responses' : 'Your classroom';

    return [
      {
        id: 'nova-study-checkin',
        subject: 'Advisory',
        title: 'NOVA Study Habits Check-In',
        description:
          'A short weekly form for understanding what students are revising, where NOVA is helping most, and which topics need teacher follow-up.',
        teacher: 'NOVA Team',
        audienceLabel: audience,
        acceptingResponses: true,
        allowMultipleResponses: false,
        published: true,
        summary: {
          responsesCount: 38,
          pendingCount: 7,
          completionRate: 84.4,
          averageDurationLabel: '2 min',
          publishedLabel: 'Published this week',
        },
        questions: [
          {
            id: 'main-subject',
            title: 'Which subject needs the most help this week?',
            type: 'dropdown',
            required: true,
            options: ['Math', 'English', 'Biology', 'History', 'Physics'],
            stats: {
              choiceStats: [
                { label: 'Math', count: 15, fraction: 0.39 },
                { label: 'English', count: 8, fraction: 0.21 },
                { label: 'Biology', count: 7, fraction: 0.18 },
              ],
            },
          },
          {
            id: 'nova-usage',
            title: 'How useful was NOVA this week?',
            type: 'linearScale',
            required: true,
            minScale: 1,
            maxScale: 5,
            stats: { averageScale: 4.2 },
          },
          {
            id: 'topic-help',
            title: 'What topic should your teacher review next?',
            type: 'paragraph',
            stats: {
              textSamples: [
                'Quadratic functions and graph transformations.',
                'More help with text evidence in English answers.',
              ],
            },
          },
        ],
      },
      {
        id: 'mock-exam-reflection',
        subject: 'Assessment',
        title: 'Mock Exam Reflection',
        description:
          'Capture how the last mock exam felt, where time was lost, and what support students want before the next assessment block.',
        teacher: 'Assessment Office',
        audienceLabel: audience,
        acceptingResponses: true,
        allowMultipleResponses: true,
        published: true,
        summary: {
          responsesCount: 52,
          pendingCount: 11,
          completionRate: 82.5,
          averageDurationLabel: '3 min',
          publishedLabel: 'Published 2 days ago',
        },
        questions: [
          {
            id: 'confidence',
            title: 'How confident did you feel before the exam?',
            type: 'multipleChoice',
            required: true,
            options: ['Very confident', 'Mostly ready', 'Unsure', 'Underprepared'],
            stats: {
              choiceStats: [
                { label: 'Mostly ready', count: 21, fraction: 0.40 },
                { label: 'Unsure', count: 18, fraction: 0.35 },
                { label: 'Underprepared', count: 9, fraction: 0.17 },
              ],
            },
          },
          {
            id: 'time-loss',
            title: 'Where did you lose the most time?',
            type: 'checkboxes',
            options: [
              'Reading the prompt',
              'Planning answers',
              'Checking work',
              'Calculations',
            ],
            stats: {
              choiceStats: [
                { label: 'Planning answers', count: 26, fraction: 0.50 },
                { label: 'Calculations', count: 19, fraction: 0.37 },
              ],
            },
          },
          {
            id: 'support-needed',
            title: 'What would help most before the next exam?',
            type: 'shortAnswer',
            stats: {
              textSamples: [
                'A worked example set with timing guidance.',
                'A revision checklist for formulas and method choice.',
              ],
            },
          },
        ],
      },
      {
        id: 'school-communication-preferences',
        subject: 'Operations',
        title: 'School Communication Preferences',
        description:
          'A quick operations form for how families and students want to receive updates, reminder timing, and urgent notice preferences.',
        teacher: 'School Office',
        audienceLabel: teacherLike ? 'Staff and families' : 'Students and families',
        acceptingResponses: false,
        allowMultipleResponses: false,
        published: true,
        summary: {
          responsesCount: 128,
          pendingCount: 0,
          completionRate: 100,
          averageDurationLabel: '1 min',
          publishedLabel: 'Closed',
        },
        questions: [
          {
            id: 'preferred-channel',
            title: 'Preferred update channel',
            type: 'multipleChoice',
            required: true,
            options: ['In-app notification', 'Email', 'SMS', 'WhatsApp'],
            stats: {
              choiceStats: [
                { label: 'In-app notification', count: 55, fraction: 0.43 },
                { label: 'WhatsApp', count: 39, fraction: 0.30 },
                { label: 'Email', count: 25, fraction: 0.20 },
              ],
            },
          },
          {
            id: 'timing',
            title: 'Best time for reminders',
            type: 'dropdown',
            options: ['Morning', 'After school', 'Evening'],
            stats: {
              choiceStats: [
                { label: 'Evening', count: 49, fraction: 0.38 },
                { label: 'After school', count: 44, fraction: 0.34 },
              ],
            },
          },
        ],
      },
    ];
  }
}