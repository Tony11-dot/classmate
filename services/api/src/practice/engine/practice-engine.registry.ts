import { Injectable } from '@nestjs/common';
import type { PracticeEngineRequest, GeneratedQuestion } from './practice-engine.types';
import type { PracticeEngine } from './practice-engine.interface';
import { LinearEquationsDeterministicEngine } from './linear-equations-deterministic.engine';
import { SystemsOfEquationsDeterministicEngine } from './systems-of-equations-deterministic.engine';
import { ProbabilityDeterministicEngine } from './probability-deterministic.engine';
import { GeometryDeterministicEngine } from './geometry-deterministic.engine';
import { FunctionsDeterministicEngine } from './functions-deterministic.engine';
import { StatisticsDeterministicEngine } from './statistics-deterministic.engine';
import { SequencesDeterministicEngine } from './sequences-deterministic.engine';
import { DerivativesDeterministicEngine } from './derivatives-deterministic.engine';
import { LimitsDeterministicEngine } from './limits-deterministic.engine';
import { QuadraticDeterministicEngine } from './quadratic-deterministic.engine';
import { TrigonometryDeterministicEngine } from './trigonometry-deterministic.engine';

@Injectable()
export class PracticeEngineRegistry {
  private readonly engines: PracticeEngine[];

  constructor(
    private readonly linearEquationsEngine: LinearEquationsDeterministicEngine,
    private readonly systemsOfEquationsEngine: SystemsOfEquationsDeterministicEngine,
    private readonly probabilityEngine: ProbabilityDeterministicEngine,
    private readonly geometryEngine: GeometryDeterministicEngine,
    private readonly functionsEngine: FunctionsDeterministicEngine,
    private readonly statisticsEngine: StatisticsDeterministicEngine,
    private readonly sequencesEngine: SequencesDeterministicEngine,
    private readonly derivativesEngine: DerivativesDeterministicEngine,
    private readonly limitsEngine: LimitsDeterministicEngine,
    private readonly quadraticEngine: QuadraticDeterministicEngine,
    private readonly trigonometryEngine: TrigonometryDeterministicEngine,
  ) {
    this.engines = [
      this.systemsOfEquationsEngine,
      this.linearEquationsEngine,
      this.probabilityEngine,
      this.functionsEngine,
      this.statisticsEngine,
      this.sequencesEngine,
      this.derivativesEngine,
      this.limitsEngine,
      this.geometryEngine,
      this.quadraticEngine,
      this.trigonometryEngine,
    ];
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[] | null> {
    for (const engine of this.engines) {
      if (engine.supports(req)) {
        return engine.generate(req);
      }
    }
    return null;
  }
}
