import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),

  // API
  PORT: z.coerce.number().int().positive().default(3000),
  JWT_SECRET: z.string().min(16, 'JWT_SECRET must be at least 16 chars'),

  // DB
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),

  ENABLE_E2E_SEED: z.coerce.boolean().default(false),

  // CORS (optional but common)
  CORS_ORIGINS: z.string().optional(),
});

export type Env = z.infer<typeof EnvSchema>;

export function parseCorsOrigins(v?: string) {
  if (!v) return [] as string[];
  return v.split(",").map(s => s.trim()).filter(Boolean);
}

export function loadEnv(): Env {
  const parsed = EnvSchema.safeParse(process.env);
  if (!parsed.success) {
    // eslint-disable-next-line no-console
    console.error('❌ Invalid environment variables:', parsed.error.flatten().fieldErrors);
    process.exit(1);
  }
  return parsed.data;
}
