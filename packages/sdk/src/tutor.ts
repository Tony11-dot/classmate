import { z } from "zod";
import { apiFetch } from "./http";
import {
  TutorAskRequestSchema,
  TutorAskResponseSchema,
  TutorCharactersResponseSchema,
  TutorThreadsResponseSchema,
  TutorMessagesResponseSchema,
} from "@classmate/contracts";

export function tutorSdk(baseUrl: string) {
  return {
    listCharacters: (args: { token?: string | null }) =>
      apiFetch({
        baseUrl,
        path: "/api/tutor/characters",
        method: "GET",
        token: args.token ?? null,
        returnSchema: TutorCharactersResponseSchema,
      }),

    listThreads: (args: { token?: string | null; characterId?: string | null }) =>
      apiFetch({
        baseUrl,
        path: "/api/tutor/threads",
        method: "GET",
        token: args.token ?? null,
        query: { characterId: args.characterId ?? undefined },
        returnSchema: TutorThreadsResponseSchema,
      }),

    listMessages: (args: { token?: string | null; threadId: string }) =>
      apiFetch({
        baseUrl,
        path: `/api/tutor/threads/${encodeURIComponent(args.threadId)}/messages`,
        method: "GET",
        token: args.token ?? null,
        returnSchema: TutorMessagesResponseSchema,
      }),

    ask: (args: { token?: string | null; body: z.input<typeof TutorAskRequestSchema> }) =>
      apiFetch({
        baseUrl,
        path: "/api/tutor/ask",
        method: "POST",
        token: args.token ?? null,
        body: args.body,
        returnSchema: TutorAskResponseSchema,
      }),
  };
}
