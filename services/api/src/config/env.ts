import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3001),
  HOST: z.string().default('127.0.0.1'),
  API_PREFIX: z.string().default('api'),

  JWT_SECRET: z.string().min(8),

  CORS_ORIGIN: z.string().optional(),

  DATABASE_URL: z.string().min(1),
});

export type Env = z.infer<typeof envSchema>;

export const env: Env = envSchema.parse(process.env);

export const corsOrigins = (() => {
  const raw = env.CORS_ORIGIN?.trim();
  if (!raw) return [];
  return raw.split(',').map((s) => s.trim()).filter(Boolean);
})();
