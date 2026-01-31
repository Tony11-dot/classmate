import { IsEmail, IsOptional, IsString, MinLength } from 'class-validator';

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
}
