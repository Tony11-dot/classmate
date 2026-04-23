import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type { GeneratedQuestion, PracticeEngineRequest } from './practice-engine.types';
import { clampTime } from './practice-engine.utils';

type ElectronicsTopic =
  | 'Ohm’s Law'
  | 'Series Circuits'
  | 'Parallel Circuits'
  | 'Current and Voltage'
  | 'Resistors'
  | 'Capacitors'
  | 'Kirchhoff Laws';

@Injectable()
export class ElectronicsDeterministicEngine implements PracticeEngine {
  readonly supportedModes = ['practice', 'flashcards', 'speedRound', 'examPrep', 'conceptBuilder', 'adaptive'] as const;

  supports(req: PracticeEngineRequest): boolean {
    const s = String(req.subject ?? '').toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return (
      s === 'electronics' ||
      t.includes('electronics') ||
      t.includes('ohm') ||
      t.includes('kirchhoff') ||
      t.includes('series') ||
      t.includes('parallel') ||
      t.includes('capacitor') ||
      t.includes('resistor') ||
      t.includes('current') ||
      t.includes('voltage')
    );
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const count = Math.max(1, Math.min(20, Number(req.questionCount ?? 5)));
        const rawSeconds = req.timePreferenceSeconds;
    const fallbackSeconds = req.difficulty === 'easy' ? 25 : req.difficulty === 'hard' ? 45 : 40;
    const seconds = rawSeconds == null
      ? fallbackSeconds
      : Math.max(5, Math.min(900, Math.round(Number(rawSeconds))));

    const topic = this.resolveTopic(req);

    const bank: GeneratedQuestion[] = [
      this.mcq(
        'Ohm’s Law',
        'A resistor has resistance 6 Ω and current 2 A. What is the voltage across it?',
        ['12 V', '3 V', '8 V', '4 V'],
        0,
        'Use V = IR = 6 × 2 = 12 V.',
        seconds,
      ),
      this.mcq(
        'Ohm’s Law',
        'A resistor has voltage 15 V across it and resistance 5 Ω. What is the current?',
        ['10 A', '3 A', '20 A', '75 A'],
        1,
        'Use I = V/R = 15/5 = 3 A.',
        seconds,
      ),
      this.mcq(
        'Ohm’s Law',
        'A resistor carries 4 A when connected to 20 V. What is its resistance?',
        ['80 Ω', '5 Ω', '16 Ω', '24 Ω'],
        1,
        'Use R = V/I = 20/4 = 5 Ω.',
        seconds,
      ),

      this.mcq(
        'Series Circuits',
        'Two resistors of 4 Ω and 6 Ω are connected in series. What is the total resistance?',
        ['24 Ω', '10 Ω', '2 Ω', '5 Ω'],
        1,
        'In series, resistances add: 4 + 6 = 10 Ω.',
        seconds,
      ),
      this.mcq(
        'Series Circuits',
        'Three resistors of 2 Ω, 3 Ω, and 5 Ω are connected in series. What is the equivalent resistance?',
        ['10 Ω', '6 Ω', '30 Ω', '1 Ω'],
        0,
        'Series resistances add directly: 2 + 3 + 5 = 10 Ω.',
        seconds,
      ),
      this.mcq(
        'Series Circuits',
        'In a series circuit, which quantity is the same through every component?',
        ['Voltage', 'Current', 'Resistance', 'Power'],
        1,
        'In a series circuit, the same current flows through every component.',
        seconds,
      ),

      this.mcq(
        'Parallel Circuits',
        'Two resistors of 6 Ω and 3 Ω are connected in parallel. What is the equivalent resistance?',
        ['2 Ω', '9 Ω', '3 Ω', '18 Ω'],
        0,
        'For parallel resistors: 1/R = 1/6 + 1/3 = 1/2, so R = 2 Ω.',
        seconds,
      ),
      this.mcq(
        'Parallel Circuits',
        'Two identical 8 Ω resistors are connected in parallel. What is the equivalent resistance?',
        ['16 Ω', '8 Ω', '4 Ω', '2 Ω'],
        2,
        'Two equal resistors in parallel give half the resistance: 8/2 = 4 Ω.',
        seconds,
      ),
      this.mcq(
        'Parallel Circuits',
        'In a parallel circuit, which quantity is the same across each branch?',
        ['Current', 'Charge', 'Voltage', 'Resistance'],
        2,
        'Each branch in a parallel circuit has the same potential difference.',
        seconds,
      ),

      this.mcq(
        'Current and Voltage',
        'What device is used to measure electric current in a circuit?',
        ['Voltmeter', 'Ammeter', 'Ohmmeter', 'Battery'],
        1,
        'An ammeter measures electric current.',
        seconds,
      ),
      this.mcq(
        'Current and Voltage',
        'What device is connected in parallel to measure potential difference?',
        ['Ammeter', 'Fuse', 'Voltmeter', 'Resistor'],
        2,
        'A voltmeter is connected in parallel to measure voltage.',
        seconds,
      ),
      this.mcq(
        'Current and Voltage',
        'Current is measured in which SI unit?',
        ['Volt', 'Ampere', 'Ohm', 'Watt'],
        1,
        'Electric current is measured in amperes (A).',
        seconds,
      ),

      this.mcq(
        'Resistors',
        'What is the SI unit of resistance?',
        ['Volt', 'Ampere', 'Watt', 'Ohm'],
        3,
        'Resistance is measured in ohms (Ω).',
        seconds,
      ),
      this.mcq(
        'Resistors',
        'If resistance increases while voltage stays constant, what happens to current?',
        ['It increases', 'It decreases', 'It stays the same', 'It becomes zero always'],
        1,
        'From I = V/R, increasing resistance lowers the current when voltage is fixed.',
        seconds,
      ),
      this.mcq(
        'Resistors',
        'A 12 Ω resistor and a 6 Ω resistor are compared. Which one allows more current under the same voltage?',
        ['12 Ω resistor', '6 Ω resistor', 'They allow equal current', 'Cannot be determined'],
        1,
        'Lower resistance gives higher current for the same voltage.',
        seconds,
      ),

      this.mcq(
        'Capacitors',
        'A capacitor primarily stores:',
        ['Magnetic field energy only', 'Electric charge', 'Resistance', 'Current'],
        1,
        'A capacitor stores electric charge and energy in an electric field.',
        seconds,
      ),
      this.mcq(
        'Capacitors',
        'The SI unit of capacitance is:',
        ['Henry', 'Farad', 'Ohm', 'Tesla'],
        1,
        'Capacitance is measured in farads (F).',
        seconds,
      ),
      this.mcq(
        'Capacitors',
        'In a simple DC circuit, an uncharged capacitor initially behaves most like:',
        ['An open switch', 'A short path', 'A battery', 'A resistor with infinite current forever'],
        1,
        'Right at the start of charging, it allows current easily before gradually behaving like an open circuit.',
        seconds,
      ),

      this.mcq(
        'Kirchhoff Laws',
        'According to Kirchhoff’s current law, the sum of currents entering a junction is:',
        ['Less than the sum leaving', 'Equal to the sum leaving', 'Always zero individually', 'Twice the sum leaving'],
        1,
        'Kirchhoff’s current law states total current entering equals total current leaving.',
        seconds,
      ),
      this.mcq(
        'Kirchhoff Laws',
        'According to Kirchhoff’s voltage law, the algebraic sum of voltages around any closed loop is:',
        ['1 V', 'Equal to total resistance', 'Zero', 'Equal to total current'],
        2,
        'Kirchhoff’s voltage law says the net voltage change around a closed loop is zero.',
        seconds,
      ),
      this.mcq(
        'Kirchhoff Laws',
        'If 5 A enters a junction and 2 A leaves through one branch, how much current must leave through the other branch?',
        ['7 A', '5 A', '3 A', '2 A'],
        2,
        'By Kirchhoff’s current law, current in equals current out, so 5 A = 2 A + 3 A.',
        seconds,
      ),
    ];

    const filtered = bank.filter((q) => q.topicMatchNote === topic);
    const chosen = filtered.length ? filtered : bank;
    return chosen.slice(0, count);
  }

  private resolveTopic(req: PracticeEngineRequest): ElectronicsTopic {
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase();

    if (t.includes('kirchhoff') || t.includes('kcl') || t.includes('kvl')) return 'Kirchhoff Laws';
    if (t.includes('ohm')) return 'Ohm’s Law';
    if (t.includes('series')) return 'Series Circuits';
    if (t.includes('parallel')) return 'Parallel Circuits';
    if (t.includes('capacitor')) return 'Capacitors';
    if (t.includes('resistor')) return 'Resistors';
    if (t.includes('current') || t.includes('voltage')) return 'Current and Voltage';

    return 'Ohm’s Law';
  }


  private selectBankForTopic(req: PracticeEngineRequest, bank: GeneratedQuestion[]): GeneratedQuestion[] {
    const wanted = String(req.topicLabel ?? '').trim().toLowerCase();

    const topicAliases: Array<{ aliases: string[]; topic: string }> = [
      { aliases: ['ohm’s law', "ohm's law", 'ohms law', 'ohm law'], topic: 'Ohm’s Law' },
      { aliases: ['series circuits', 'series circuit'], topic: 'Series Circuits' },
      { aliases: ['parallel circuits', 'parallel circuit'], topic: 'Parallel Circuits' },
      { aliases: ['current and voltage', 'current', 'voltage'], topic: 'Current and Voltage' },
      { aliases: ['resistors', 'resistor'], topic: 'Resistors' },
      { aliases: ['capacitors', 'capacitor'], topic: 'Capacitors' },
      { aliases: ['kirchhoff laws', 'kirchhoff', 'kcl', 'kvl'], topic: 'Kirchhoff Laws' },
    ];

    const matched = topicAliases.find((row) => row.aliases.includes(wanted));
    if (!matched) return bank;

    const filtered = bank.filter(
      (q) => String(q.topicMatchNote ?? '').trim() === matched.topic,
    );

    return filtered.length ? filtered : bank;
  }

  private mcq(
    topicMatchNote: ElectronicsTopic,
    prompt: string,
    options: string[],
    correctIndex: number,
    explanation: string,
    recommendedTimeSeconds: number,
  ): GeneratedQuestion {
    return {
      prompt,
      options,
      correctIndex,
      correctAnswerText: options[correctIndex],
      explanation,
      recommendedTimeSeconds,
      topicMatchNote,
    };
  }
}
