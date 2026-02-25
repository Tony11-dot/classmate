import { z } from 'zod';
import { HttpClient } from './http-client';
import { LoginRequest, LoginResponse } from '../contracts/auth.contract';

export class AuthSdk {
  constructor(private readonly http: HttpClient) {}

  login(req: z.infer<typeof LoginRequest>) {
    return this.http.post('/api/auth/login', LoginRequest.parse(req), LoginResponse);
  }
}
