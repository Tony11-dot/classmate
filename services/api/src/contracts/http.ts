import { z } from 'zod';

export const Id = z.string().min(1);

export const IsoDateString = z.string().datetime().or(z.string().min(1)); // pragmatic

export const PaginationQuery = z.object({
  cursor: z.string().optional(),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export type PaginationQuery = z.infer<typeof PaginationQuery>;
