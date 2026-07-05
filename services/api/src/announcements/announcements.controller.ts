import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role, ALL_APP_ROLES } from '../auth/roles';
import { AnnouncementsService } from './announcements.service';

@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
@Controller('announcements')
export class AnnouncementsController {
  constructor(private readonly announcements: AnnouncementsService) {}

  @Post()
  @Roles(Role.ADMIN, Role.SECRETARY, Role.TEACHER)
  create(
    @Req() req: any,
    @Body()
    body: {
      title: string;
      body: string;
      pinned?: boolean;
      publishAt?: string;
      expiresAt?: string;
      targets?: {
        userId?: string;
        role?: 'STUDENT' | 'TEACHER' | 'ADMIN' | 'PARENT' | 'SECRETARY';
        grade?: number;
        cohortId?: string;
      }[];
    },
  ) {
    return this.announcements.create(req.user, body);
  }

  @Get('feed')
  feed(
    @Req() req: any,
    @Query('take') take?: string,
    @Query('skip') skip?: string,
  ) {
    return this.announcements.feed(req.user, {
      take: take ? Number(take) : 20,
      skip: skip ? Number(skip) : 0,
    });
  }

  @Get('mine')
  @Roles(Role.ADMIN, Role.SECRETARY, Role.TEACHER)
  mine(
    @Req() req: any,
    @Query('take') take?: string,
    @Query('skip') skip?: string,
  ) {
    return this.announcements.mine(req.user, {
      take: take ? Number(take) : 50,
      skip: skip ? Number(skip) : 0,
    });
  }

  @Get('targets')
  @Roles(Role.ADMIN, Role.SECRETARY, Role.TEACHER)
  targets(@Req() req: any) {
    return this.announcements.targets(req.user);
  }

  @Get('unread-count')
  unreadCount(@Req() req: any) {
    return this.announcements.unreadCount(req.user);
  }

  @Post('mark-seen')
  markSeen(@Req() req: any, @Body() body: { announcementId?: string }) {
    return this.announcements.markSeen(req.user, body);
  }
}
