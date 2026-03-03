import { z } from 'zod';

/**
 * NOTE: SDK imports a bunch of schemas. We keep them present (even if permissive)
 * so contracts + SDK compile. Tighten later as we lock endpoints.
 */

export const OkSchema = z.object({ ok: z.boolean().default(true) }).passthrough();

export const TutorRoleSchema = z.enum(['USER', 'ASSISTANT', 'SYSTEM']);

export const TutorSessionSchema = z.object({
  id: z.string(),
  characterId: z.string().nullable().optional(),
  createdAt: z.string().optional(),
}).passthrough();

export const TutorMessageSchema = z.object({
  id: z.string().optional(),
  role: TutorRoleSchema,
  content: z.string(),
  createdAt: z.string().optional(),
}).passthrough();

/** ---- Create session ---- */
export const CreateSessionBodySchema = z.object({
  characterId: z.string().optional(),
}).passthrough();

export const TutorCreateSessionResponseSchema = z
  .object({
    session: TutorSessionSchema.optional(),
    id: z.string().optional(),
  })
  .passthrough()
  .transform((x) => ({ id: (x.session?.id ?? x.id) as string }));

// SDK expects this name:
export const CreateSessionResponseSchema = TutorCreateSessionResponseSchema;

/** ---- Sessions list / get ---- */
export const ListSessionsQuerySchema = z.object({
  characterId: z.string().optional(),
}).passthrough();

export const ListSessionsResponseSchema = z.object({
  items: z.array(TutorSessionSchema).default([]),
}).passthrough();

export const GetSessionResponseSchema = z.object({
  session: TutorSessionSchema.optional(),
  messages: z.array(TutorMessageSchema).default([]),
}).passthrough();

/** ---- Characters ---- */
export const ListCharactersQuerySchema = z.object({
  subject: z.string().optional(),
}).passthrough();

export const ListCharactersResponseSchema = z.object({
  items: z.array(z.any()).default([]),
}).passthrough();

/** ---- Materials ---- */
export const ListMaterialsQuerySchema = z.object({
  q: z.string().optional(),
}).passthrough();

export const ListMaterialsResponseSchema = z.object({
  items: z.array(z.any()).default([]),
}).passthrough();

export const CreateMaterialBodySchema = z.object({}).passthrough();
export const CreateMaterialResponseSchema = z.any();

/** ---- Brain + learning profile ---- */
export const GetMyBrainSnapshotResponseSchema = z.any();
export const RebuildMyBrainSnapshotResponseSchema = z.any();

export const GetMyLearningProfileResponseSchema = z.any();
export const UpsertMyLearningProfileBodySchema = z.object({}).passthrough();
export const UpsertMyLearningProfileResponseSchema = z.any();

/** ---- Messaging / reply ---- */
export const AddMessageBodySchema = z.object({
  role: TutorRoleSchema,
  content: z.string(),
}).passthrough();

export const AddMessageResponseSchema = z.object({
  ok: z.boolean().default(true),
}).passthrough();

export const ReplyBodySchema = z.object({
  role: TutorRoleSchema.optional(),
  content: z.string().optional(),
}).passthrough();

export const ReplyResponseSchema = z.any();

// SSE events (keep permissive)
export const ReplyStreamEventSchema = z.any();

export type TutorMessage = z.infer<typeof TutorMessageSchema>;
export type TutorCreateSessionResponse = z.infer<typeof TutorCreateSessionResponseSchema>;
