import {
  IsBoolean,
  IsDateString,
  IsEmail,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(2)
  name!: string;

  @IsString()
  @MinLength(3)
  password!: string;

  // Optional: only allow safe roles if you later decide to.
  // For now we ignore any role attempts to prevent privilege escalation.
  @IsOptional()
  @IsString()
  role?: string;

  // --- Consent / age (Israel Privacy Amendment 13) ---------------------------
  // The signup UI presents an explicit "I accept the Privacy Policy & Terms"
  // checkbox (and, for a minor, a guardian-permission affirmation). These fields
  // record that acceptance. They are optional on the wire so older clients keep
  // working; the backend still stamps a consent timestamp on every new account.
  @IsOptional()
  @IsBoolean()
  acceptedTerms?: boolean;

  @IsOptional()
  @IsBoolean()
  guardianConsent?: boolean;

  /// ISO date (YYYY-MM-DD). Optional date of birth for age-appropriate handling.
  @IsOptional()
  @IsDateString()
  birthDate?: string;

  @IsOptional()
  @IsString()
  consentVersion?: string;
}
