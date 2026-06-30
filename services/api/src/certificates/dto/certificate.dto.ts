import { IsArray, IsInt, IsObject, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateCertificateDto {
  @IsOptional()
  @IsString()
  @MaxLength(64)
  studentId?: string;

  @IsString()
  @MaxLength(160)
  studentDisplayName!: string;

  @IsOptional()
  @IsString()
  @MaxLength(64)
  nationalId?: string;

  @IsString()
  @MaxLength(64)
  cohortId!: string;

  @IsString()
  @MaxLength(160)
  homeroomTeacher!: string;

  @IsString()
  @MaxLength(160)
  principalName!: string;

  @IsString()
  @MaxLength(8)
  language!: string;

  @IsOptional()
  @IsString()
  @MaxLength(4000)
  publisherNote?: string;

  @IsString()
  @MaxLength(16)
  schoolYear!: string;

  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  semesterWeights?: number[];

  @IsOptional()
  @IsObject()
  snapshot?: Record<string, any>;

  @IsOptional()
  @IsString()
  @MaxLength(1024)
  pdfUrl?: string;
}
