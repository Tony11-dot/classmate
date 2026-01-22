import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateAlertSettingsDto } from './dto/update-alert-settings.dto';

const DEFAULTS = {
  minGrade: 70,
  maxAbsences: 1,
  maxLates: 3,
};

@Injectable()
export class ParentAlertsService {
  constructor(private prisma: PrismaService) {}

  private async assertLink(parentId: string, studentId: string) {
    const ok = await this.prisma.parentChild.findFirst({
      where: { parentId, childId: studentId, status: 'APPROVED' as any },
    });
    if (!ok) throw new ForbiddenException();
  }

  async get(parentId: string, studentId: string) {
    await this.assertLink(parentId, studentId);

    const row = await this.prisma.alertSettings.upsert({
      where: { ownerId_studentId: { ownerId: parentId, studentId } },
      create: {
        ownerId: parentId,
        studentId,
        minGrade: DEFAULTS.minGrade,
        maxAbsences: DEFAULTS.maxAbsences,
        maxLates: DEFAULTS.maxLates,
      },
      update: {},
    });

    return { ok: true, studentId, settings: row, defaults: DEFAULTS };
  }

  async update(parentId: string, dto: UpdateAlertSettingsDto) {
    await this.assertLink(parentId, dto.studentId);

    const row = await this.prisma.alertSettings.upsert({
      where: {
        ownerId_studentId: { ownerId: parentId, studentId: dto.studentId },
      },
      create: {
        ownerId: parentId,
        studentId: dto.studentId,
        minGrade: dto.minGrade ?? DEFAULTS.minGrade,
        maxAbsences: dto.maxAbsences ?? DEFAULTS.maxAbsences,
        maxLates: dto.maxLates ?? DEFAULTS.maxLates,
      },
      update: {
        minGrade: dto.minGrade,
        maxAbsences: dto.maxAbsences,
        maxLates: dto.maxLates,
      },
    });

    return { ok: true, settings: row };
  }
}
