export type TutorReplyMode = 'deterministic' | 'llm';

export type TutorReplyGen = {
  content: string;
  refs?: string;
  excerpt?: string;
};

export type TutorReplyProviderArgs = {
  question: string;
  topic: string;
  ctx: any;
  materials: any[];
};

export interface TutorReplyProvider {
  mode: TutorReplyMode;
  generate(args: TutorReplyProviderArgs): Promise<TutorReplyGen>;
}
