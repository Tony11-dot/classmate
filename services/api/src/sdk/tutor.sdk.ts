import type { z } from 'zod';
import { HttpClient } from './http-client';
import {
  AddMessageBodySchema,
  AddMessageResponseSchema,
  CreateMaterialBodySchema,
  CreateMaterialResponseSchema,
  CreateSessionBodySchema,
  CreateSessionResponseSchema,
  GetMyBrainSnapshotResponseSchema,
  GetMyLearningProfileResponseSchema,
  GetSessionResponseSchema,
  ListCharactersQuerySchema,
  ListCharactersResponseSchema,
  ListMaterialsQuerySchema,
  ListMaterialsResponseSchema,
  ListSessionsQuerySchema,
  ListSessionsResponseSchema,
  OkSchema,
  RebuildMyBrainSnapshotResponseSchema,
  ReplyBodySchema,
  ReplyResponseSchema,
  UpsertMyLearningProfileBodySchema,
  UpsertMyLearningProfileResponseSchema,
} from '../contracts/tutor.contract';

function qs(input?: Record<string, any>) {
  const p = new URLSearchParams();
  for (const [k, v] of Object.entries(input ?? {})) {
    if (v === undefined || v === null) continue;
    p.set(k, String(v));
  }
  const s = p.toString();
  return s ? `?${s}` : '';
}

export class TutorSdk {
  constructor(private readonly http: HttpClient) {}

  // ---- Profile ----
  async getMyProfile() {
    return this.http.get('/tutor/me/profile', GetMyLearningProfileResponseSchema);
  }

  async upsertMyProfile(body: z.input<typeof UpsertMyLearningProfileBodySchema>) {
    const b = UpsertMyLearningProfileBodySchema.parse(body);
    return this.http.post('/tutor/me/profile', b, UpsertMyLearningProfileResponseSchema);
  }

  // ---- Brain ----
  async getMyBrain() {
    return this.http.get('/tutor/me/brain', GetMyBrainSnapshotResponseSchema);
  }

  async rebuildMyBrain() {
    return this.http.post('/tutor/me/brain/rebuild', {}, RebuildMyBrainSnapshotResponseSchema);
  }

  // ---- Materials ----
  async listMaterials(query: z.input<typeof ListMaterialsQuerySchema> = {}) {
    const q = ListMaterialsQuerySchema.parse(query);
    return this.http.get(`/tutor/materials${qs(q)}`, ListMaterialsResponseSchema);
  }

  async createMaterial(body: z.input<typeof CreateMaterialBodySchema>) {
    const b = CreateMaterialBodySchema.parse(body);
    return this.http.post('/tutor/materials', b, CreateMaterialResponseSchema);
  }

  // ---- Characters ----
  async listCharacters(query: z.input<typeof ListCharactersQuerySchema> = {}) {
    const q = ListCharactersQuerySchema.parse(query);
    return this.http.get(`/tutor/characters${qs(q)}`, ListCharactersResponseSchema);
  }

  // ---- Sessions ----
  async createSession(body: z.input<typeof CreateSessionBodySchema>) {
    const b = CreateSessionBodySchema.parse(body);
    return this.http.post('/tutor/sessions', b, CreateSessionResponseSchema);
  }

  async listSessions(query: z.input<typeof ListSessionsQuerySchema> = {}) {
    const q = ListSessionsQuerySchema.parse(query);
    return this.http.get(`/tutor/sessions${qs(q)}`, ListSessionsResponseSchema);
  }

  async getSession(id: string) {
    return this.http.get(`/tutor/sessions/${encodeURIComponent(id)}`, GetSessionResponseSchema);
  }

  async addMessage(id: string, body: z.input<typeof AddMessageBodySchema>) {
    const b = AddMessageBodySchema.parse(body);
    return this.http.post(`/tutor/sessions/${encodeURIComponent(id)}/messages`, b, AddMessageResponseSchema);
  }

  async reply(id: string, body: z.input<typeof ReplyBodySchema>) {
    const b = ReplyBodySchema.parse(body);
    return this.http.post(`/tutor/sessions/${encodeURIComponent(id)}/reply`, b, ReplyResponseSchema);
  }

  // ---- misc ----
  async health() {
    return this.http.get('/tutor/materials' + qs({ take: 1 }), OkSchema.catchall((await import('zod')).z.any()));
  }
}
