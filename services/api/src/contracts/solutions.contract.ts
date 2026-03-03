import { z } from 'zod';

export const SolutionsListQuerySchema = z.object({
  q: z.string().optional(),
  subject: z.string().optional(),
  grade: z.coerce.number().int().optional(),
  cursor: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(50).optional(),
});

export const SolutionSchema = z.object({
  id: z.string(),
  title: z.string(),
  body: z.string(),
  subject: z.string().nullable().optional(),
  grade: z.number().int().nullable().optional(),
  createdAt: z.string(),
  authorId: z.string().nullable().optional(),
  likeCount: z.number().int().default(0),
  commentCount: z.number().int().default(0),
});

export const SolutionsListResponseSchema = z.object({
  items: z.array(SolutionSchema).default([]),
  nextCursor: z.string().nullable().optional(),
});

export const SolutionsCreateBodySchema = z.object({
  title: z.string().min(1),
  body: z.string().min(1),
  subject: z.string().optional(),
  grade: z.coerce.number().int().optional(),
});

export type SolutionsListQuery = z.infer<typeof SolutionsListQuerySchema>;
export type Solution = z.infer<typeof SolutionSchema>;
export type SolutionsListResponse = z.infer<typeof SolutionsListResponseSchema>;
export type SolutionsCreateBody = z.infer<typeof SolutionsCreateBodySchema>;
