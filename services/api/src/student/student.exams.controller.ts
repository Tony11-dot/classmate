import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import {
  BadRequestException,
  Controller,
  Get,
  NotFoundException,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PrismaService } from '../prisma/prisma.service';

@UseGuards(JwtAuthGuard)
@Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN)
@Controller('student/exams')
export class StudentExamsController {
  constructor(private readonly prisma: PrismaService) {}

  private async studentCohortId(uid: string): Promise<string | null> {
    const sp = await this.prisma.studentProfile.findUnique({
      where: { userId: uid },
      select: { cohortId: true },
    });
    return sp?.cohortId ?? null;
  }

  @Get()
  async list(@Req() req: any) {
    const uid = String(req?.user?.sub ?? req?.user?.id ?? '');
    if (!uid) throw new BadRequestException('Missing identity');

    const cohortId = await this.studentCohortId(uid);

    const exams = await this.prisma.teacherExam.findMany({
      where: {
        published: true,
        OR: [
          { targetStudentIds: { has: uid } },
          ...(cohortId ? [{ targetCohortIds: { has: cohortId } }] : []),
        ],
      },
      select: {
        id: true,
        title: true,
        subject: true,
        date: true,
        maxGrade: true,
        attachments: true,
        teacher: { select: { name: true, displayName: true } },
        assessments: {
          where: { grades: { some: { studentId: uid } } },
          select: {
            id: true,
            grades: { where: { studentId: uid }, select: { grade: true, comment: true }, take: 1 },
          },
          take: 1,
        },
      },
      orderBy: [{ date: 'desc' }, { id: 'desc' }],
    });

    return { ok: true, items: exams.map((e: any) => this.#shape(e)) };
  }

  @Get(':examId')
  async detail(@Req() req: any, @Param('examId') examId: string) {
    const uid = String(req?.user?.sub ?? req?.user?.id ?? '');
    if (!uid) throw new BadRequestException('Missing identity');

    const cohortId = await this.studentCohortId(uid);

    const exam = await this.prisma.teacherExam.findFirst({
      where: {
        id: String(examId),
        published: true,
        OR: [
          { targetStudentIds: { has: uid } },
          ...(cohortId ? [{ targetCohortIds: { has: cohortId } }] : []),
        ],
      },
      select: {
        id: true,
        title: true,
        subject: true,
        date: true,
        maxGrade: true,
        attachments: true,
        teacher: { select: { name: true, displayName: true } },
        assessments: {
          where: { grades: { some: { studentId: uid } } },
          select: {
            id: true,
            grades: { where: { studentId: uid }, select: { grade: true, comment: true }, take: 1 },
          },
          take: 1,
        },
      },
    });

    if (!exam) throw new NotFoundException('Exam not found or not accessible');
    return { ok: true, exam: this.#shape(exam) };
  }

  #shape(e: any) {
    const assessment = e.assessments?.[0] ?? null;
    const gr = assessment?.grades?.[0] ?? null;
    return {
      id: e.id,
      title: e.title,
      subject: e.subject ?? null,
      date: e.date?.toISOString() ?? null,
      maxGrade: e.maxGrade ?? 100,
      attachments: Array.isArray(e.attachments) ? e.attachments : [],
      teacherName: e.teacher?.displayName ?? e.teacher?.name ?? null,
      assessmentId: assessment?.id ?? null,
      grade: gr?.grade ?? null,
      gradeComment: gr?.comment ?? null,
      graded: gr !== null,
    };
  }
}
