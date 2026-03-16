import type { PracticeEngineRequest, GeneratedQuestion } from './practice-engine.types';

export interface PracticeEngine {
  supports(req: PracticeEngineRequest): boolean;
  generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]>;
}
