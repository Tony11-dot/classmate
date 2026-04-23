import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type { PracticeEngineRequest, GeneratedQuestion } from './practice-engine.types';

type TrigItem = {
  prompt: string;
  answer: string;
  explanation: string;
};

@Injectable()
export class TrigonometryDeterministicEngine implements PracticeEngine {
  readonly supportedModes = ['practice', 'flashcards', 'speedRound', 'examPrep', 'conceptBuilder', 'adaptive'] as const;

  supports(req: PracticeEngineRequest): boolean {
    const s = req.subject.toLowerCase();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase();

    return s === 'math' && t.includes('trigonometry');
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const bank =
      req.difficulty === 'easy'
        ? this.easyBank()
        : req.difficulty === 'medium'
        ? this.mediumBank()
        : req.difficulty === 'hard'
        ? this.hardBank()
        : this.hardBank();

    const out: GeneratedQuestion[] = [];
    for (let i = 0; i < req.questionCount; i++) {
      const item = bank[i % bank.length];
      const options = this.makeOptions(item.answer);

      out.push({
        prompt: item.prompt,
        options,
        correctIndex: options.indexOf(item.answer),
        correctAnswerText: item.answer,
        explanation: item.explanation,
        recommendedTimeSeconds: this.timeFor(req.difficulty, req.timePreferenceSeconds),
        topicMatchNote: 'Trigonometry',
      });
    }

    return out;
  }

  private timeFor(difficulty: string, overrideSeconds: number | null): number {
    if (overrideSeconds != null && Number.isFinite(overrideSeconds)) {
      return Math.max(5, Math.min(900, Math.round(overrideSeconds)));
    }

    switch (difficulty) {
      case 'easy':
        return 25;
      case 'medium':
        return 40;
      case 'hard':
        return 60;
      case 'olympiad':
        return 75;
      default:
        return 45;
    }
  }

  private easyBank(): TrigItem[] {
    return [
      {
        prompt: 'What is the exact value of sin(30°)?',
        answer: '1/2',
        explanation: 'Using standard special-angle values, sin(30°) = 1/2.',
      },
      {
        prompt: 'What is the exact value of cos(60°)?',
        answer: '1/2',
        explanation: 'Using standard special-angle values, cos(60°) = 1/2.',
      },
      {
        prompt: 'What is the exact value of tan(45°)?',
        answer: '1',
        explanation: 'For 45°, the legs are equal, so tan(45°) = 1.',
      },
      {
        prompt: 'What is the principal value of arccos(0)?',
        answer: '90°',
        explanation: 'cos(90°) = 0, so the principal value is 90°.',
      },
      {
        prompt: 'If sin θ = 3/5 and θ is acute, what is cos θ?',
        answer: '4/5',
        explanation: 'Using a 3-4-5 triangle, cos θ = adjacent/hypotenuse = 4/5.',
      },
      {
        prompt: 'If cos θ = 12/13 and θ is acute, what is sin θ?',
        answer: '5/13',
        explanation: 'Using a 5-12-13 triangle, sin θ = opposite/hypotenuse = 5/13.',
      },
      {
        prompt: 'What is the exact value of sin(90°)?',
        answer: '1',
        explanation: 'On the unit circle, the y-coordinate at 90° is 1.',
      },
      {
        prompt: 'What is the exact value of cos(0°)?',
        answer: '1',
        explanation: 'On the unit circle, the x-coordinate at 0° is 1.',
      },
      {
        prompt: 'What is the exact value of tan(0°)?',
        answer: '0',
        explanation: 'tan(0°) = sin(0°)/cos(0°) = 0/1 = 0.',
      },
      {
        prompt: 'What is the exact value of sin(45°)?',
        answer: '√2/2',
        explanation: 'From the 45°-45°-90° triangle, sin(45°) = √2/2.',
      },
    ];
  }

  private mediumBank(): TrigItem[] {
    return [
      {
        prompt: 'What is the exact value of cos(120°)?',
        answer: '-1/2',
        explanation: '120° is in quadrant II with reference angle 60°, so cos(120°) = -cos(60°) = -1/2.',
      },
      {
        prompt: 'What is the exact value of sin(150°)?',
        answer: '1/2',
        explanation: '150° is in quadrant II with reference angle 30°, so sin(150°) = sin(30°) = 1/2.',
      },
      {
        prompt: 'If tan θ = 3/4 and θ is acute, what is sin θ?',
        answer: '3/5',
        explanation: 'Using a 3-4-5 triangle, sin θ = opposite/hypotenuse = 3/5.',
      },
      {
        prompt: 'If tan θ = 3/4 and θ is acute, what is cos θ?',
        answer: '4/5',
        explanation: 'Using a 3-4-5 triangle, cos θ = adjacent/hypotenuse = 4/5.',
      },
      {
        prompt: 'What is the exact value of sec(60°)?',
        answer: '2',
        explanation: 'sec(60°) = 1/cos(60°) = 1/(1/2) = 2.',
      },
      {
        prompt: 'What is the exact value of csc(30°)?',
        answer: '2',
        explanation: 'csc(30°) = 1/sin(30°) = 1/(1/2) = 2.',
      },
      {
        prompt: 'What is the exact value of sin(2·45°)?',
        answer: '1',
        explanation: 'sin(90°) = 1.',
      },
      {
        prompt: 'What is the exact value of cos(2·45°)?',
        answer: '0',
        explanation: 'cos(90°) = 0.',
      },
      {
        prompt: 'Solve in 0° ≤ x ≤ 360°: sin x = 1/2. Which is a solution?',
        answer: '30°',
        explanation: 'sin x = 1/2 at 30° and 150°, so 30° is a correct solution.',
      },
      {
        prompt: 'Solve in 0° ≤ x ≤ 360°: cos x = -1/2. Which is a solution?',
        answer: '120°',
        explanation: 'cos x = -1/2 at 120° and 240°, so 120° is a correct solution.',
      },
    ];
  }

  private hardBank(): TrigItem[] {
    return [
      {
        prompt: 'Find the exact value of sin(75°).',
        answer: '(√6+√2)/4',
        explanation: 'sin(75°)=sin(45°+30°)=sin45°cos30°+cos45°sin30°=(√2/2)(√3/2)+(√2/2)(1/2)=(√6+√2)/4.',
      },
      {
        prompt: 'Find the exact value of cos(75°).',
        answer: '(√6-√2)/4',
        explanation: 'cos(75°)=cos(45°+30°)=cos45°cos30°-sin45°sin30°=(√2/2)(√3/2)-(√2/2)(1/2)=(√6-√2)/4.',
      },
      {
        prompt: 'Find the exact value of tan(75°).',
        answer: '2+√3',
        explanation: 'tan(75°)=tan(45°+30°)=(1+1/√3)/(1-1/√3)=2+√3.',
      },
      {
        prompt: 'If sin θ = 3/5 and θ is in quadrant II, what is cos θ?',
        answer: '-4/5',
        explanation: 'Using a 3-4-5 triangle and quadrant II sign, cos θ = -4/5.',
      },
      {
        prompt: 'If cos θ = 5/13 and θ is in quadrant IV, what is sin θ?',
        answer: '-12/13',
        explanation: 'Using a 5-12-13 triangle and quadrant IV sign, sin θ = -12/13.',
      },
      {
        prompt: 'What is the exact value of sin(15°)?',
        answer: '(√6-√2)/4',
        explanation: 'sin(15°)=sin(45°-30°)=sin45°cos30°-cos45°sin30°=(√6-√2)/4.',
      },
      {
        prompt: 'What is the exact value of cos(15°)?',
        answer: '(√6+√2)/4',
        explanation: 'cos(15°)=cos(45°-30°)=cos45°cos30°+sin45°sin30°=(√6+√2)/4.',
      },
      {
        prompt: 'If tan θ = 3/4 and θ is acute, what is sin(2θ)?',
        answer: '24/25',
        explanation: 'With sin θ=3/5 and cos θ=4/5, sin(2θ)=2sinθcosθ=2·(3/5)·(4/5)=24/25.',
      },
      {
        prompt: 'If sin θ = 5/13 and θ is acute, what is cos(2θ)?',
        answer: '119/169',
        explanation: 'cos(2θ)=1-2sin²θ=1-2·(25/169)=119/169.',
      },
      {
        prompt: 'Solve in 0° ≤ x ≤ 360°: 2sin²x - 3sin x + 1 = 0. Which is a solution?',
        answer: '30°',
        explanation: 'Let y=sin x. Then 2y²-3y+1=(2y-1)(y-1)=0, so y=1/2 or y=1. Thus x can be 30°, 150°, or 90°, so 30° is a correct solution.',
      },
    ];
  }

  private makeOptions(answer: string): string[] {
    const presets: Record<string, string[]> = {
      '1/2': ['1/2', '√2/2', '1', '0'],
      '1': ['1', '0', '-1', '1/2'],
      '0': ['0', '1', '-1', '1/2'],
      '√2/2': ['√2/2', '1/2', '√3/2', '1'],
      '-1/2': ['-1/2', '1/2', '-√2/2', '0'],
      '3/5': ['3/5', '4/5', '5/13', '12/13'],
      '4/5': ['4/5', '3/5', '5/13', '12/13'],
      '2': ['2', '1/2', '√3', '1'],
      '30°': ['30°', '60°', '90°', '120°'],
      '90°': ['90°', '0°', '60°', '180°'],
      '(√6+√2)/4': ['(√6+√2)/4', '(√6-√2)/4', '√3/2', '√2/2'],
      '(√6-√2)/4': ['(√6-√2)/4', '(√6+√2)/4', '1/2', '√2/2'],
      '2+√3': ['2+√3', '2-√3', '√3', '1+√3'],
      '-4/5': ['-4/5', '4/5', '-3/5', '3/5'],
      '-12/13': ['-12/13', '12/13', '-5/13', '5/13'],
      '24/25': ['24/25', '7/25', '3/5', '4/5'],
      '119/169': ['119/169', '69/169', '-119/169', '25/169'],
      '120°': ['120°', '60°', '240°', '300°'],
    };

    const arr = presets[answer];
    if (arr && new Set(arr).size === 4) return arr;

    return [answer, '1', '0', '-1'];
  }
}
