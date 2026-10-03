import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

/// Global validation runs with `forbidNonWhitelisted`, so every field the
/// endpoints accept has to be declared here. Length caps are the outer bound a
/// hostile client is held to; the real rules (a plausible address, the eight
/// character password floor) live in `ClassNotesAccountService` so they are
/// enforced on every path into it, including the reset flow.
export class ClassNotesRegisterDto {
  @IsString()
  @MaxLength(320)
  email!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(200)
  password!: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  name?: string;
}

export class ClassNotesLoginDto {
  @IsString()
  @MaxLength(320)
  email!: string;

  @IsString()
  @MaxLength(200)
  password!: string;
}

export class ClassNotesForgotPasswordDto {
  @IsString()
  @MaxLength(320)
  email!: string;
}

export class ClassNotesResetPasswordDto {
  @IsString()
  @MaxLength(256)
  token!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(200)
  password!: string;
}

export class ClassNotesChangePasswordDto {
  @IsString()
  @MaxLength(200)
  currentPassword!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(200)
  newPassword!: string;
}

export class ClassNotesUpdateProfileDto {
  @IsString()
  @MaxLength(120)
  name!: string;
}

export class ClassNotesDeleteAccountDto {
  @IsString()
  @MaxLength(200)
  password!: string;
}
