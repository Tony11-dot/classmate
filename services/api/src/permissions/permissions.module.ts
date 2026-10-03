import { Global, Module } from '@nestjs/common';
import { PermissionsService } from './permissions.service';
import { PermissionsController } from './permissions.controller';

/**
 * Global so any feature module (admin, teacher, certificates, cmail) can inject
 * PermissionsService for defense-in-depth grant checks without re-importing.
 * PrismaModule is already @Global, so the service's only dependency resolves.
 */
@Global()
@Module({
  controllers: [PermissionsController],
  providers: [PermissionsService],
  exports: [PermissionsService],
})
export class PermissionsModule {}
