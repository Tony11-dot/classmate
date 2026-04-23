import type {
  PracticeEngineRequest,
  GeneratedQuestion,
  EngineMode,
} from './practice-engine.types';

export interface PracticeEngine {
  supportedModes?: readonly EngineMode[];
  supports(req: PracticeEngineRequest): boolean;
  generate(req: PracticeEngineRequest): Promise<GeneratedQuestion[]>;
}
