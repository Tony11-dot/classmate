import { IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class UpdateAlertSettingsDto {
  @IsString()
  studentId!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  minGrade?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  maxAbsences?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  maxLates?: number;
}
