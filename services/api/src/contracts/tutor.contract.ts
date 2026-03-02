import { z } from 'zod';

export const TutorLanguageSchema = z.enum(['en', 'he', 'ar']);
export type TutorLanguage = z.infer<typeof TutorLanguageSchema>;

export const TutorCharacterSubjectSchema = z.enum([
  'GENERAL',
  'MATH',
  'PHYSICS',
  'CS',
  'ENGLISH',
  'HEBREW',
  'ARABIC',
]);
export type TutorCharacterSubject = z.infer<typeof TutorCharacterSubjectSchema>;

export const MaterialSourceSchema = z.enum(['BAGRUT', 'TEACHER', 'BOOK', 'OTHER']);
export type MaterialSource = z.infer<typeof MaterialSourceSchema>;

export const TutorMessageRoleSchema = z.enum(['USER', 'ASSISTANT', 'SYSTEM']);
export type TutorMessageRole = z.infer<typeof TutorMessageRoleSchema>;

export const OkSchema = z.object({ ok: z.literal(true) });

/** -----------------------------
 * Learning Profile
 * ---------------------------- */
export const LearningProfileSchema = z.object({
  id: z.string(),
  userId: z.string(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),

  targetCurriculum: z.string().nullable().optional(),
  targetGrade: z.number().int().nullable().optional(),
  preferredLanguage: TutorLanguageSchema.nullable().optional(),

  tone: z.string().nullable().optional(),
  verbosity: z.number().int().min(1).max(10).nullable().optional(),
  explainStyle: z.string().nullable().optional(),
  emojiOk: z.boolean().optional(),

  strengths: z.array(z.string()).optional(),
  weaknesses: z.array(z.string()).optional(),
  goals: z.array(z.string()).optional(),

  maxDepth: z.number().int().nullable().optional(),
});

export const GetMyLearningProfileResponseSchema = OkSchema.extend({
  profile: LearningProfileSchema.nullable(),
});
export type GetMyLearningProfileResponse = z.infer<
  typeof GetMyLearningProfileResponseSchema
>;

export const UpsertMyLearningProfileBodySchema = z
  .object({
    targetCurriculum: z.string().optional(),
    targetGrade: z.number().int().min(7).max(12).optional(),
    preferredLanguage: TutorLanguageSchema.optional(),

    tone: z.string().optional(),
    verbosity: z.number().int().min(1).max(10).optional(),
    explainStyle: z.string().optional(),
    emojiOk: z.boolean().optional(),

    strengths: z.array(z.string()).optional(),
    weaknesses: z.array(z.string()).optional(),
    goals: z.array(z.string()).optional(),

    maxDepth: z.number().int().min(1).max(5).optional(),
  })
  .strict();

export const UpsertMyLearningProfileResponseSchema = OkSchema.extend({
  profile: LearningProfileSchema,
});
export type UpsertMyLearningProfileResponse = z.infer<
  typeof UpsertMyLearningProfileResponseSchema
>;

/** -----------------------------
 * Brain Snapshot
 * ---------------------------- */
export const StudentBrainSnapshotSchema = z.object({
  id: z.string(),
  createdAt: z.string().datetime(),
  userId: z.string(),
  cohortId: z.string().nullable(),
  metrics: z.unknown(),
});

export const GetMyBrainSnapshotResponseSchema = OkSchema.extend({
  snapshot: StudentBrainSnapshotSchema.nullable(),
});
export type GetMyBrainSnapshotResponse = z.infer<
  typeof GetMyBrainSnapshotResponseSchema
>;

export const RebuildMyBrainSnapshotResponseSchema = OkSchema.extend({
  snapshot: StudentBrainSnapshotSchema,
});
export type RebuildMyBrainSnapshotResponse = z.infer<
  typeof RebuildMyBrainSnapshotResponseSchema
>;

/** -----------------------------
 * Materials
 * ---------------------------- */
export const MaterialSchema = z.object({
  id: z.string(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),

  cohortId: z.string().nullable(),
  courseId: z.string().nullable(),

  title: z.string(),
  subject: z.string().nullable(),
  grade: z.number().int().nullable(),
  language: z.string().nullable(),
  source: MaterialSourceSchema,

  content: z.string(),
  tags: z.array(z.string()),
});

export const ListMaterialsQuerySchema = z
  .object({
    subject: z.string().optional(),
    grade: z.number().int().optional(),
    language: z.string().optional(),
    q: z.string().optional(),
    take: z.number().int().min(1).max(50).optional(),
  })
  .strict();

export const ListMaterialsResponseSchema = OkSchema.extend({
  materials: z.array(MaterialSchema),
});
export type ListMaterialsResponse = z.infer<typeof ListMaterialsResponseSchema>;

export const CreateMaterialBodySchema = z
  .object({
    subject: z.string(),
    title: z.string(),
    content: z.string().optional(),
    grade: z.number().int().optional(),
    targetGrade: z.number().int().optional(),
    language: z.string().optional(),
    source: MaterialSourceSchema.optional(),
    sourceType: z.string().optional(), // legacy mapping
    tags: z.array(z.string()).optional(),
  })
  .strict();

export const CreateMaterialResponseSchema = OkSchema.extend({
  material: MaterialSchema,
});
export type CreateMaterialResponse = z.infer<typeof CreateMaterialResponseSchema>;

/** -----------------------------
 * Characters
 * ---------------------------- */
export const TutorCharacterSchema = z.object({
  id: z.string(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),

  cohortId: z.string().nullable(),
  subject: TutorCharacterSubjectSchema,
  name: z.string(),

  tone: z.string().nullable(),
  verbosity: z.number().int().nullable(),
  explainStyle: z.string().nullable(),

  curriculum: z.string().nullable(),
  maxGrade: z.number().int().nullable(),
  language: z.string().nullable(),

  systemNotes: z.string().nullable(),
});

export const ListCharactersQuerySchema = z
  .object({ subject: TutorCharacterSubjectSchema.optional() })
  .strict();

export const ListCharactersResponseSchema = OkSchema.extend({
  characters: z.array(TutorCharacterSchema),
});
export type ListCharactersResponse = z.infer<typeof ListCharactersResponseSchema>;

/** -----------------------------
 * Sessions + Messages
 * ---------------------------- */
export const TutorSessionSchema = z.object({
  id: z.string(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),

  characterId: z.string().nullable(),
  userId: z.string(),
  courseId: z.string().nullable(),
  cohortId: z.string().nullable(),

  title: z.string().nullable(),
  topic: z.string().nullable(),
});

export const TutorMessageSchema = z.object({
  id: z.string(),
  createdAt: z.string().datetime(),
  sessionId: z.string(),
  role: TutorMessageRoleSchema,
  content: z.string(),
  sources: z.array(z.string()),
});

export const CreateSessionBodySchema = z
  .object({
    subject: TutorCharacterSubjectSchema.optional(),
    characterId: z.string().optional(),
    title: z.string().optional(),
    topic: z.string().optional(),
  })
  .strict();

export const CreateSessionResponseSchema = OkSchema.extend({
  session: TutorSessionSchema,
});
export type CreateSessionResponse = z.infer<typeof CreateSessionResponseSchema>;

export const ListSessionsQuerySchema = z
  .object({
    characterId: z.string().optional(),
  })
  .strict();

export const ListSessionsResponseSchema = OkSchema.extend({
  sessions: z.array(TutorSessionSchema),
});
export type ListSessionsResponse = z.infer<typeof ListSessionsResponseSchema>;

export const GetSessionResponseSchema = OkSchema.extend({
  session: TutorSessionSchema,
  messages: z.array(TutorMessageSchema),
});
export type GetSessionResponse = z.infer<typeof GetSessionResponseSchema>;

export const AddMessageBodySchema = z
  .object({
    role: TutorMessageRoleSchema.optional(), // default USER
    content: z.string().min(1).optional(),
    sources: z.array(z.string()).optional(),
  })
  .strict();

export const AddMessageResponseSchema = OkSchema.extend({
  message: TutorMessageSchema,
});
export type AddMessageResponse = z.infer<typeof AddMessageResponseSchema>;

export const ReplyBodySchema = z
  .object({
    // reply trigger: empty body allowed; backend uses latest USER message
    content: z.string().min(1).optional(),
  })
  .strict();

export const ReplyResponseSchema = OkSchema.extend({
  assistantMessage: TutorMessageSchema,
});
export type ReplyResponse = z.infer<typeof ReplyResponseSchema>;
