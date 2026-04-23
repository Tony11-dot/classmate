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
import { PhysicsForcesDeterministicEngine } from './physics-forces-deterministic.engine';
import { PhysicsNewtonLawsDeterministicEngine } from './physics-newton-laws-deterministic.engine';
import { PhysicsKinematicsDeterministicEngine } from './physics-kinematics-deterministic.engine';
import { PhysicsMomentumDeterministicEngine } from './physics-momentum-deterministic.engine';
import { PhysicsThermodynamicsDeterministicEngine } from './physics-thermodynamics-deterministic.engine';
import { PhysicsOpticsDeterministicEngine } from './physics-optics-deterministic.engine';
import { PhysicsWavesDeterministicEngine } from './physics-waves-deterministic.engine';
import { PhysicsCircuitsDeterministicEngine } from './physics-circuits-deterministic.engine';
import { PhysicsElectricFieldDeterministicEngine } from './physics-electric-field-deterministic.engine';
import { PhysicsElectricityDeterministicEngine } from './physics-electricity-deterministic.engine';
import { PhysicsEnergyDeterministicEngine } from './physics-energy-deterministic.engine';
import { PhysicsMagnetismDeterministicEngine } from './physics-magnetism-deterministic.engine';
import { PhysicsRelativityDeterministicEngine } from './physics-relativity-deterministic.engine';
import { PolynomialsDeterministicEngine } from './polynomials-deterministic.engine';
import { SetTheoryDeterministicEngine } from './set-theory-deterministic.engine';
import { ElectronicsDeterministicEngine } from './electronics-deterministic.engine';
import { BroadCatalogDeterministicEngine } from './broad-catalog-deterministic.engine';

@Injectable()
export class PracticeEngineRegistry {
  private supportsRequestedMode(
    engine: PracticeEngine,
    mode: PracticeEngineRequest['mode'],
  ) {
    const supportedModes = engine.supportedModes;
    if (!Array.isArray(supportedModes) || supportedModes.length === 0) {
      return mode === 'practice';
    }

    return supportedModes.includes(mode);
  }

  private ensureQuestionCount(questions: any[], requested: number) {
    if (!Array.isArray(questions)) return [];
    return questions.slice(0, requested);
  }

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
    private readonly polynomialsEngine: PolynomialsDeterministicEngine,
    private readonly setTheoryEngine: SetTheoryDeterministicEngine,
    private readonly broadCatalogEngine: BroadCatalogDeterministicEngine,
    private readonly physicsKinematicsEngine: PhysicsKinematicsDeterministicEngine,
    private readonly physicsNewtonLawsEngine: PhysicsNewtonLawsDeterministicEngine,
    private readonly physicsForcesEngine: PhysicsForcesDeterministicEngine,
    private readonly physicsEnergyEngine: PhysicsEnergyDeterministicEngine,
    private readonly physicsMagnetismEngine: PhysicsMagnetismDeterministicEngine,
    private readonly physicsRelativityEngine: PhysicsRelativityDeterministicEngine,
    private readonly physicsMomentumEngine: PhysicsMomentumDeterministicEngine,
    private readonly physicsElectricityEngine: PhysicsElectricityDeterministicEngine,
    private readonly physicsElectricFieldEngine: PhysicsElectricFieldDeterministicEngine,
    private readonly physicsCircuitsEngine: PhysicsCircuitsDeterministicEngine,
    private readonly physicsWavesEngine: PhysicsWavesDeterministicEngine,
    private readonly physicsOpticsEngine: PhysicsOpticsDeterministicEngine,
    private readonly physicsThermodynamicsEngine: PhysicsThermodynamicsDeterministicEngine,
    private readonly electronicsEngine: ElectronicsDeterministicEngine,
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
      this.polynomialsEngine,
      this.setTheoryEngine,
      this.broadCatalogEngine,
      this.physicsKinematicsEngine,
      this.physicsNewtonLawsEngine,
      this.physicsForcesEngine,
      this.physicsEnergyEngine,
      this.physicsMagnetismEngine,
      this.physicsRelativityEngine,
      this.physicsMomentumEngine,
      this.physicsElectricityEngine,
      this.physicsElectricFieldEngine,
      this.physicsCircuitsEngine,
      this.physicsWavesEngine,
      this.physicsOpticsEngine,
      this.physicsThermodynamicsEngine,
      this.electronicsEngine,
    ];
  }

  async generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[] | null> {
    for (const engine of this.engines) {
      if (!this.supportsRequestedMode(engine, req.mode)) {
        continue;
      }

      if (engine.supports(req)) {
        const questions = await engine.generate(req);
        return this.ensureQuestionCount(questions, req.questionCount ?? 2);
      }
    }
    return null;
  }
}
