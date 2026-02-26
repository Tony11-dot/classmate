import { z } from 'zod';
import { HttpClient } from './http-client';
import { LoginRequestSchema, LoginResponseSchema } from '../contracts/auth.contract';

export class AuthSdk {
  constructor(private readonly http: HttpClient) {}

  login(req: z.infer<typeof LoginRequestSchema>) {
    return this.http.post('/api/auth/login', LoginRequestSchema.parse(req), LoginResponseSchema);
  }
}
