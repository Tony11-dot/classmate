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
  ReplyBodySchema,
  ReplyResponseSchema,
  UpsertMyLearningProfileBodySchema,
  UpsertMyLearningProfileResponseSchema,
  RebuildMyBrainSnapshotResponseSchema,
} from '../contracts/tutor.contract';

export class TutorSdk {
  constructor(private http: HttpClient) {}

  // ---- profile ----
  getMyProfile() {
    return this.http.get('/tutor/me/profile', GetMyLearningProfileResponseSchema);
  }

  upsertMyProfile(body: unknown) {
    const parsedBody = UpsertMyLearningProfileBodySchema.parse(body);
    return this.http.post(
      '/tutor/me/profile',
      parsedBody,
      UpsertMyLearningProfileResponseSchema,
    );
  }

  // ---- brain ----
  getMyBrain() {
    return this.http.get('/tutor/me/brain', GetMyBrainSnapshotResponseSchema);
  }

  rebuildMyBrain() {
    return this.http.post(
      '/tutor/me/brain/rebuild',
      {},
      RebuildMyBrainSnapshotResponseSchema,
    );
  }

  // ---- materials ----
  listMaterials(query: unknown) {
    const q = ListMaterialsQuerySchema.parse(query);
    // HttpClient.get takes (path, schema) only. Encode query into URL.
    const qs = new URLSearchParams(
      Object.entries(q).flatMap(([k, v]) =>
        v === undefined || v === null ? [] : [[k, String(v)]],
      ),
    ).toString();
    const path = qs ? `/tutor/materials?${qs}` : '/tutor/materials';
    return this.http.get(path, ListMaterialsResponseSchema);
  }

  createMaterial(body: unknown) {
    const b = CreateMaterialBodySchema.parse(body);
    return this.http.post('/tutor/materials', b, CreateMaterialResponseSchema);
  }

  // ---- characters ----
  listCharacters(query: unknown) {
    const q = ListCharactersQuerySchema.parse(query);
    const qs = new URLSearchParams(
      Object.entries(q).flatMap(([k, v]) =>
        v === undefined || v === null ? [] : [[k, String(v)]],
      ),
    ).toString();
    const path = qs ? `/tutor/characters?${qs}` : '/tutor/characters';
    return this.http.get(path, ListCharactersResponseSchema);
  }

  // ---- sessions ----
  createSession(body: unknown) {
    const b = CreateSessionBodySchema.parse(body);
    return this.http.post('/tutor/sessions', b, CreateSessionResponseSchema);
  }

  listSessions(query: unknown) {
    const q = ListSessionsQuerySchema.parse(query);
    const qs = new URLSearchParams(
      Object.entries(q).flatMap(([k, v]) =>
        v === undefined || v === null ? [] : [[k, String(v)]],
      ),
    ).toString();
    const path = qs ? `/tutor/sessions?${qs}` : '/tutor/sessions';
    return this.http.get(path, ListSessionsResponseSchema);
  }

  getSession(id: string) {
    return this.http.get(
      `/tutor/sessions/${encodeURIComponent(id)}`,
      GetSessionResponseSchema,
    );
  }

  addMessage(sessionId: string, body: unknown) {
    const b = AddMessageBodySchema.parse(body);
    return this.http.post(
      `/tutor/sessions/${encodeURIComponent(sessionId)}/messages`,
      b,
      AddMessageResponseSchema,
    );
  }

  reply(sessionId: string, body: unknown) {
    const b = ReplyBodySchema.parse(body);
    return this.http.post(
      `/tutor/sessions/${encodeURIComponent(sessionId)}/reply`,
      b,
      ReplyResponseSchema,
    );
  }
}
