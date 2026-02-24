import { z } from 'zod';

export type HttpClientOptions = {
  baseUrl: string;
  getToken?: () => string | undefined;
  defaultHeaders?: Record<string, string>;
};

export class HttpClient {
  constructor(private readonly opts: HttpClientOptions) {}

  private headers(extra?: Record<string, string>) {
    const token = this.opts.getToken?.();
    return {
      'Content-Type': 'application/json',
      ...(this.opts.defaultHeaders ?? {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(extra ?? {}),
    };
  }

  async get<T>(path: string, schema: z.ZodType<T>): Promise<T> {
    const res = await fetch(this.opts.baseUrl + path, {
      method: 'GET',
      headers: this.headers(),
    });

    const text = await res.text();
    const json = text ? JSON.parse(text) : null;

    if (!res.ok) {
      const msg = typeof json?.message === 'string' ? json.message : `HTTP ${res.status}`;
      throw new Error(msg);
    }

    return schema.parse(json);
  }

  async post<TReq, TRes>(path: string, body: TReq, schema: z.ZodType<TRes>): Promise<TRes> {
    const res = await fetch(this.opts.baseUrl + path, {
      method: 'POST',
      headers: this.headers(),
      body: JSON.stringify(body),
    });

    const text = await res.text();
    const json = text ? JSON.parse(text) : null;

    if (!res.ok) {
      const msg = typeof json?.message === 'string' ? json.message : `HTTP ${res.status}`;
      throw new Error(msg);
    }

    return schema.parse(json);
  }
}
