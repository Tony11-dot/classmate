export type FactualEvidenceItem = {
  sourceId: string;
  title: string;
  snippet: string;
  url?: string;
  publishedAt?: string;
};


export type FactualGeneratedSeed = {
  prompt: string;
  options: string[];
  correctIndex: number;
  explanation: string;
  factSourceIds: string[];
};

export type FactualQuestionSeed = {
  subject: string;
  topic: string;
  facts: string[];
  evidence: FactualEvidenceItem[];
  difficulty: 'easy' | 'medium' | 'hard' | 'olympiad' | 'adaptive';
  mode:
    | 'practice'
    | 'flashcards'
    | 'speedRound'
    | 'examPrep'
    | 'conceptBuilder'
    | 'adaptive';
  questionCount: number;
};



export type FactualQuestionDraftSeed = {
  stem: string;
  acceptedAnswers: string[];
  explanation: string;
  factSourceIds: string[];
};

export type FactualQuestionSeedResult = {
  ok: boolean;
  subject: string;
  topic: string;
  confidence: number;
  needsClarification: boolean;
  seeds: FactualQuestionDraftSeed[];
  evidence: FactualEvidenceItem[];
  gaps: string[];
};

export type FactualQuizFactPack = {
  ok: boolean;
  subject: string;
  topic: string;
  confidence: number;
  needsClarification: boolean;
  facts: string[];
  evidence: FactualEvidenceItem[];
  gaps: string[];
};
