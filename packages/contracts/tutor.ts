import { z } from "zod";
import { ApiOkSchema } from "./http";

export const TutorCharacterSchema = z.object({
  id: z.string(),
  name: z.string(),
  subject: z.string().optional(),
  description: z.string().optional(),
  avatarUrl: z.string().url().optional(),
});

export const TutorThreadSchema = z.object({
  id: z.string(),
  characterId: z.string(),
  title: z.string().optional(),
  createdAt: z.string(), // ISO
  updatedAt: z.string(), // ISO
});

export const TutorMessageSchema = z.object({
  id: z.string(),
  threadId: z.string(),
  role: z.enum(["user", "assistant", "system"]),
  content: z.string(),
  createdAt: z.string(), // ISO
});

export const TutorAskRequestSchema = z.object({
  characterId: z.string(),
  threadId: z.string().optional(),
  message: z.string().min(1),
});

export const TutorAskResponseSchema = ApiOkSchema(
  z.object({
    thread: TutorThreadSchema,
    message: TutorMessageSchema, // assistant reply
  })
);

export const TutorCharactersResponseSchema = ApiOkSchema(z.array(TutorCharacterSchema));
export const TutorThreadsResponseSchema = ApiOkSchema(z.array(TutorThreadSchema));
export const TutorMessagesResponseSchema = ApiOkSchema(z.array(TutorMessageSchema));

export type TutorCharacter = z.infer<typeof TutorCharacterSchema>;
export type TutorThread = z.infer<typeof TutorThreadSchema>;
export type TutorMessage = z.infer<typeof TutorMessageSchema>;
export type TutorAskRequest = z.infer<typeof TutorAskRequestSchema>;
export type TutorAskResponse = z.infer<typeof TutorAskResponseSchema>;
