import { UserRole } from '../../auth/roles';

export type ActorType = 'USER';

export interface ActorContext {
  type: ActorType;
  userId: string;
  role: UserRole;

  // Multi-tenant / school-scoped context
  schoolId?: string;

  // "acting as" context (parent -> selected student)
  actingStudentId?: string;

  // Optional: parentId/teacherId/studentId domain ids if you split them
  studentId?: string;
  parentId?: string;
  teacherId?: string;
  adminId?: string;
}
