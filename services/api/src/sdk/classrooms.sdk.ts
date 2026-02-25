import { z } from 'zod';
import { HttpClient } from './http-client';
import { ClassroomDetailDto, ClassroomSummaryDto } from '../contracts/classrooms.contract';

export class ClassroomsSdk {
  constructor(private readonly http: HttpClient) {}

  listStudent() {
    return this.http.get('/api/student/classrooms', z.array(ClassroomSummaryDto));
  }

  getStudent(id: string) {
    return this.http.get(`/api/student/classrooms/${encodeURIComponent(id)}`, ClassroomDetailDto);
  }

  listParent() {
    return this.http.get('/api/parent/classrooms', z.array(ClassroomSummaryDto));
  }

  getParent(id: string) {
    return this.http.get(`/api/parent/classrooms/${encodeURIComponent(id)}`, ClassroomDetailDto);
  }

  listAdmin() {
    return this.http.get('/api/admin/classrooms', z.array(ClassroomSummaryDto));
  }

  getAdmin(id: string) {
    return this.http.get(`/api/admin/classrooms/${encodeURIComponent(id)}`, ClassroomDetailDto);
  }
}
