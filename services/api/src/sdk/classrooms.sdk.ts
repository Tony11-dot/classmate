import { z } from 'zod';
import { HttpClient } from './http-client';

export class ClassroomsSdk {
  constructor(private readonly http: HttpClient) {}

  listStudent() {
  }

  getStudent(id: string) {
  }

  listParent() {
  }

  getParent(id: string) {
  }

  listAdmin() {
  }

  getAdmin(id: string) {
  }
}
