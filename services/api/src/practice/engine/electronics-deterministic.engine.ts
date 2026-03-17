import { Injectable } from '@nestjs/common';
import type { PracticeEngine } from './practice-engine.interface';
import type { GeneratedQuestion, PracticeEngineRequest } from './practice-engine.types';

@Injectable()
export class ElectronicsDeterministicEngine implements PracticeEngine {
  supports(req: PracticeEngineRequest): boolean {
    const s = String(req.subject ?? '').toLowerCase().trim();
    const t = `${req.topicLabel} ${req.topicPathText} ${req.strictPromptSummary}`.toLowerCase().trim();
    return s === 'electronics' || t.includes('electronics') || t.includes('ohm') || t.includes('kirchhoff');
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]> {
    const count = Math.max(1, Math.min(20, Number(req.questionCount ?? 5)));
    const seconds = Math.max(5, Math.min(900, Math.round(Number.isFinite(Number(req.timePreferenceSeconds)) ? Number(req.timePreferenceSeconds) : (req.difficulty === 'easy' ? 25 : 40))));

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
        'Series Circuits',
        'Two resistors of 4 Ω and 6 Ω are connected in series. What is the total resistance?',
        ['24 Ω', '10 Ω', '2 Ω', '5 Ω'],
        1,
        'In series, resistances add: 4 + 6 = 10 Ω.',
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
        'Resistors',
        'What is the SI unit of resistance?',
        ['Volt', 'Ampere', 'Watt', 'Ohm'],
        3,
        'Resistance is measured in ohms (Ω).',
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
    ];

    return bank.slice(0, count);
  }

  private mcq(
    topicMatchNote: string,
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
