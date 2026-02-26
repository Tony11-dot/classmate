export interface TutorSession {
  id: string;
  characterId?: string;
  title?: string;
}

export interface CreateSessionInput {
  subject?: string;
  title?: string;
}

export interface TutorReplyResponse {
  message: string;
  sources?: any[];
}
