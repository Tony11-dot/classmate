import { Body, Controller, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { Role } from '../../auth/roles';
import { z } from 'zod';
import { PrismaService } from '../../prisma/prisma.service';

const CreateTemplateBodySchema = z.object({
  schoolId: z.string().min(1),
  kind: z.enum(['GRADE', 'MAJOR', 'COHORT', 'STUDENT']),
  name: z.string().min(1),
  grade: z.number().int().min(1).max(12).optional(),
  section: z.number().int().min(1).max(99).optional(),
  major: z.string().min(1).optional(),
});

const BulkSlotsBodySchema = z.object({
  slots: z
    .array(
      z.object({
        dayOfWeek: z.number().int().min(0).max(6),
        period: z.number().int().min(1).max(10),
        teacherId: z.string().min(1).nullable().optional(),
        location: z.string().min(1).nullable().optional(),
      }),
    )
    .min(1),
});

const BindCohortBodySchema = z.object({
  cohortId: z.string().min(1),
  priority: z.number().int().min(0).max(1000).optional(),
});

const BindStudentsBodySchema = z.object({
  studentIds: z.array(z.string().min(1)).min(1),
  priority: z.number().int().min(0).max(1000).optional(),
});

@UseGuards(JwtAuthGuard)
@Roles(Role.ADMIN)
@Controller('admin/schedule/templates')
export class ScheduleTemplatesController {
  constructor(private readonly prisma: PrismaService) {}

  @Post()
  async create(@Body() body: any) {
    const b = CreateTemplateBodySchema.parse(body);
    const t = await this.prisma.scheduleTemplate.create({
      data: {
        schoolId: b.schoolId,
        kind: b.kind,
        name: b.name,
        grade: b.grade,
        section: b.section,
        major: b.major,
      },
    });
    return { ok: true, template: t };
  }

  @Post(':id/slots/bulk')
  async bulkSlots(@Param('id') id: string, @Body() body: any) {
    const b = BulkSlotsBodySchema.parse(body);

    await this.prisma.scheduleTemplateSlot.deleteMany({ where: { templateId: id } });

    await this.prisma.scheduleTemplateSlot.createMany({
      data: b.slots.map((s) => ({
        templateId: id,
        dayOfWeek: s.dayOfWeek,
        period: s.period,
        teacherId: s.teacherId ?? null,
        location: s.location ?? null,
      })),
    });

    return { ok: true };
  }

  @Post(':id/bind/cohort')
  async bindCohort(@Param('id') id: string, @Body() body: any) {
    const b = BindCohortBodySchema.parse(body);
    await this.prisma.cohortScheduleTemplate.upsert({
      where: { cohortId_templateId: { cohortId: b.cohortId, templateId: id } },
      update: { priority: b.priority ?? 50 },
      create: { cohortId: b.cohortId, templateId: id, priority: b.priority ?? 50 },
    });
    return { ok: true };
  }

  @Post(':id/bind/students')
  async bindStudents(@Param('id') id: string, @Body() body: any) {
    const b = BindStudentsBodySchema.parse(body);
    await this.prisma.studentScheduleTemplate.createMany({
      data: b.studentIds.map((studentId) => ({
        studentId,
        templateId: id,
        priority: b.priority ?? 10,
      })),
      skipDuplicates: true,
    });
    return { ok: true };
  }
}
