import { Module } from '@nestjs/common';
import { PracticeController } from './practice.controller';
import { PracticeService } from './practice.service';
import { PracticeEngineRegistry } from './engine/practice-engine.registry';
import { LinearEquationsDeterministicEngine } from './engine/linear-equations-deterministic.engine';
import { SystemsOfEquationsDeterministicEngine } from './engine/systems-of-equations-deterministic.engine';
import { QuadraticDeterministicEngine } from './engine/quadratic-deterministic.engine';
import { TrigonometryDeterministicEngine } from './engine/trigonometry-deterministic.engine';

@Module({
  controllers: [PracticeController],
  providers: [
    PracticeService,
    PracticeEngineRegistry,
    LinearEquationsDeterministicEngine,
    SystemsOfEquationsDeterministicEngine,
    QuadraticDeterministicEngine,
    TrigonometryDeterministicEngine,
  ],
})
export class PracticeModule {}
