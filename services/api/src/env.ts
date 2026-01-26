import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),

  // Required
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),

  // Optional (but strongly recommended for prod)
  JWT_SECRET: z.string().min(16).optional(),

  // Comma-separated allowlist for production CORS.
  // Example: "https://app.classmate.com,https://admin.classmate.com"
  CORS_ORIGINS: z.string().optional(),
});

export type AppEnv = z.infer<typeof envSchema>;

export function loadEnv(): AppEnv {
  const parsed = envSchema.safeParse(process.env);
  if (!parsed.success) {
    const msg = parsed.error.issues
      .map((i) => `${i.path.join('.') || '(root)'}: ${i.message}`)
      .join('\n');
    throw new Error('Invalid environment variables:\n' + msg);
  }

  const env = parsed.data;

  // Safety: in production, require JWT_SECRET (if your auth relies on it)
  if (env.NODE_ENV === 'production' && !env.JWT_SECRET) {
    throw new Error('JWT_SECRET is required in production');
  }

  return env;
}

// helper: parse CORS allowlist
export function parseCorsOrigins(raw?: string): string[] {
  if (!raw) return [];
  return raw
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
}
