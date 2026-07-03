import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

export const CMAIL_AUDIENCES = [
  'SCHOOL',
  'STUDENTS',
  'TEACHERS',
  'PARENTS',
  'STAFF',
  'GRADES',
  'COHORTS',
  'USERS',
] as const;
export type CMailAudienceKind = (typeof CMAIL_AUDIENCES)[number];

export class CMailAttachmentDto {
  /// Must point at this API's own /uploads/ storage — validated server-side
  /// so a mail can never carry an external (phishing) link as an attachment.
  @IsString()
  @MaxLength(1000)
  url!: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  mimeType?: string;

  @IsOptional()
  @IsString()
  @MaxLength(300)
  fileName?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  fileSize?: number;
}

export class SendCMailDto {
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  subject!: string;

  @IsOptional()
  @IsString()
  @MaxLength(20000)
  body?: string;

  @IsIn(CMAIL_AUDIENCES as unknown as string[])
  audience!: CMailAudienceKind;

  /// For audience=GRADES: grade levels (e.g. [10, 11]).
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @IsInt({ each: true })
  grades?: number[];

  /// For audience=COHORTS.
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(100)
  @IsString({ each: true })
  cohortIds?: string[];

  /// For audience=USERS: specific people (validated against the school).
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(2000)
  @IsString({ each: true })
  userIds?: string[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => CMailAttachmentDto)
  attachments?: CMailAttachmentDto[];
}
