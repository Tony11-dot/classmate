import { IsOptional, IsString, MaxLength } from 'class-validator';

export class ReportMessageDto {
  @IsString()
  @MaxLength(191)
  threadId!: string;

  @IsString()
  @MaxLength(191)
  messageId!: string;

  /// Optional free-text reason. Capped at 500 chars to discourage
  /// abuse and keep admin triage scannable.
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;
}
