import { z } from 'zod';

export const CursorSchema = z.string().min(1);

export const SolutionsListQuerySchema = z.object({
  limit: z.coerce.number().int().positive().max(50).optional(),
  cursor: CursorSchema.optional(),
});
export type SolutionsListQuery = z.infer<typeof SolutionsListQuerySchema>;

export const SolutionSchema = z
  .object({
    id: z.string().min(1),
    createdAt: z.string().optional(),
  })
  .passthrough();
export type Solution = z.infer<typeof SolutionSchema>;

export const SolutionsListResponseSchema = z
  .object({
    items: z.array(SolutionSchema),
    nextCursor: CursorSchema.nullable().optional(),
  })
  .passthrough();
export type SolutionsListResponse = z.infer<typeof SolutionsListResponseSchema>;
