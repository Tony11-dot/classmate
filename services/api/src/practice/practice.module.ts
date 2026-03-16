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
  ],
})
export class PracticeModule {}
