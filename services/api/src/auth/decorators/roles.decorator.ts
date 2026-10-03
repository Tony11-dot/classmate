import { SetMetadata } from '@nestjs/common';
import { Role, CLASSNOTES_ROLE } from '../roles';
export const ROLES_KEY = 'roles';

/// `CLASSNOTES_ROLE` is accepted alongside the school roles but is NOT a member
/// of the `Role` enum, because it is not a role in the school: it belongs to
/// ClassNotes' own accounts. Widening the signature here, rather than adding a
/// member to `Role`, keeps it out of anything that treats that enum as the list
/// of roles a school user can hold.
export const Roles = (...roles: (Role | typeof CLASSNOTES_ROLE)[]) =>
  SetMetadata(ROLES_KEY, roles);
