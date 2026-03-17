import { Module } from '@nestjs/common';
import { PracticeController } from './practice.controller';
import { PracticeService } from './practice.service';
import { PracticeEngineRegistry } from './engine/practice-engine.registry';
import { LinearEquationsDeterministicEngine } from './engine/linear-equations-deterministic.engine';
import { SystemsOfEquationsDeterministicEngine } from './engine/systems-of-equations-deterministic.engine';
import { ProbabilityDeterministicEngine } from './engine/probability-deterministic.engine';
import { GeometryDeterministicEngine } from './engine/geometry-deterministic.engine';
import { FunctionsDeterministicEngine } from './engine/functions-deterministic.engine';
import { StatisticsDeterministicEngine } from './engine/statistics-deterministic.engine';
import { SequencesDeterministicEngine } from './engine/sequences-deterministic.engine';
import { DerivativesDeterministicEngine } from './engine/derivatives-deterministic.engine';
import { LimitsDeterministicEngine } from './engine/limits-deterministic.engine';
import { QuadraticDeterministicEngine } from './engine/quadratic-deterministic.engine';
import { TrigonometryDeterministicEngine } from './engine/trigonometry-deterministic.engine';
import { PhysicsKinematicsDeterministicEngine } from './engine/physics-kinematics-deterministic.engine';
import { PhysicsNewtonLawsDeterministicEngine } from './engine/physics-newton-laws-deterministic.engine';
import { PhysicsForcesDeterministicEngine } from './engine/physics-forces-deterministic.engine';
import { PhysicsEnergyDeterministicEngine } from './engine/physics-energy-deterministic.engine';
import { ElectronicsDeterministicEngine } from './engine/electronics-deterministic.engine';
import { PhysicsMagnetismDeterministicEngine } from './engine/physics-magnetism-deterministic.engine';
import { PhysicsRelativityDeterministicEngine } from './engine/physics-relativity-deterministic.engine';
import { PolynomialsDeterministicEngine } from './engine/polynomials-deterministic.engine';
import { SetTheoryDeterministicEngine } from './engine/set-theory-deterministic.engine';
import { PhysicsMomentumDeterministicEngine } from './engine/physics-momentum-deterministic.engine';
import { PhysicsThermodynamicsDeterministicEngine } from './engine/physics-thermodynamics-deterministic.engine';
import { PhysicsOpticsDeterministicEngine } from './engine/physics-optics-deterministic.engine';
import { PhysicsWavesDeterministicEngine } from './engine/physics-waves-deterministic.engine';
import { PhysicsCircuitsDeterministicEngine } from './engine/physics-circuits-deterministic.engine';
import { PhysicsElectricFieldDeterministicEngine } from './engine/physics-electric-field-deterministic.engine';
import { PhysicsElectricityDeterministicEngine } from './engine/physics-electricity-deterministic.engine';

@Module({
  controllers: [PracticeController],
  providers: [
    PracticeService,
    PracticeEngineRegistry,
    LinearEquationsDeterministicEngine,
    SystemsOfEquationsDeterministicEngine,
    ProbabilityDeterministicEngine,
    GeometryDeterministicEngine,
    FunctionsDeterministicEngine,
    StatisticsDeterministicEngine,
    SequencesDeterministicEngine,
    DerivativesDeterministicEngine,
    LimitsDeterministicEngine,
    QuadraticDeterministicEngine,
    TrigonometryDeterministicEngine,
    PhysicsKinematicsDeterministicEngine,
    PhysicsNewtonLawsDeterministicEngine,
    PhysicsForcesDeterministicEngine,
    PhysicsEnergyDeterministicEngine,
    ElectronicsDeterministicEngine,
    PhysicsMagnetismDeterministicEngine,
    PhysicsRelativityDeterministicEngine,
    PolynomialsDeterministicEngine,
    SetTheoryDeterministicEngine,
    PhysicsMomentumDeterministicEngine,
    PhysicsElectricityDeterministicEngine,
    PhysicsElectricFieldDeterministicEngine,
    PhysicsCircuitsDeterministicEngine,
    PhysicsWavesDeterministicEngine,
    PhysicsOpticsDeterministicEngine,
    PhysicsThermodynamicsDeterministicEngine,
  ],
})
export class PracticeModule {}
