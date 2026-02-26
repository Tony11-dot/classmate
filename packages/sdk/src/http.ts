import { z } from "zod";
import {
  ApiErrorSchema,
  ApiOkSchema,
  type ApiError,
  type ApiOk,
} from "@classmate/contracts";

/**
 * Typed fetch that:
 * - sends JSON
 * - throws a typed error if response is not ok
 * - parses the JSON response with a provided zod schema
 */
export async function apiFetch<TReturnSchema extends z.ZodTypeAny>(args: {
  baseUrl: string;
  path: string;
  method?: "GET" | "POST" | "PUT" | "PATCH" | "DELETE";
  token?: string | null;
  body?: unknown;
  query?: Record<string, string | number | boolean | undefined | null>;
  returnSchema: TReturnSchema;
}): Promise<z.infer<TReturnSchema>> {
  const url = new URL(args.path, args.baseUrl.endsWith("/") ? args.baseUrl : args.baseUrl + "/");
  if (args.query) {
    for (const [k, v] of Object.entries(args.query)) {
      if (v === undefined || v === null) continue;
      url.searchParams.set(k, String(v));
    }
  }

  const res = await fetch(url.toString(), {
    method: args.method ?? "GET",
    headers: {
      "Content-Type": "application/json",
      ...(args.token ? { Authorization: `Bearer ${args.token}` } : {}),
    },
    body: args.body === undefined ? undefined : JSON.stringify(args.body),
  });

  const text = await res.text();
  const json = text ? safeJsonParse(text) : undefined;

  if (!res.ok) {
    // Try to coerce into our standard error envelope
    const parsed = ApiErrorSchema.safeParse(json);
    if (parsed.success) {
      throw Object.assign(new Error(parsed.data.error.message), { api: parsed.data } as { api: ApiError });
    }

    // Fallback error
    throw new Error(`HTTP ${res.status}: ${text.slice(0, 300)}`);
  }

  // Standard ok envelope is allowed but not required; schema decides.
  const out = args.returnSchema.safeParse(json);
  if (!out.success) {
    throw new Error(`Response schema mismatch: ${out.error.message}`);
  }
  return out.data;
}

function safeJsonParse(s: string): unknown {
  try {
    return JSON.parse(s);
  } catch {
    return s;
  }
}

export type ApiOkOf<T> = ApiOk<T>;
export { ApiOkSchema };
