import { IsString, MaxLength, MinLength } from 'class-validator';

/// Body shape for POST /auth/me/password. MaxLength bound prevents a
/// malicious client from streaming a 1 GB "password" to exhaust bcrypt.
export class ChangePasswordDto {
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  currentPassword!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(200)
  newPassword!: string;
}
