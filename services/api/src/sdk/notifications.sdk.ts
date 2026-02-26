import { z } from 'zod';
import {
} from '../contracts/index'; // TODO: define notifications contract
import { HttpClient } from './http-client';

export class NotificationsSdk {
  constructor(private readonly http: HttpClient) {}

  list() {
  }

  }

  seenAll() {
  }

  create(input: any) {
    return this.http.post('/api/notifications', input, z.any());
  }
}
