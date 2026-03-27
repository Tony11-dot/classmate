import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export class SendMessageDto {
  @IsString()
  @MaxLength(191)
  threadId!: string;

  @IsOptional()
  @IsString()
  @MaxLength(4000)
  text?: string;

  @IsOptional()
  @IsString()
  @IsIn(['TEXT', 'IMAGE', 'VOICE', 'VIDEO', 'FILE'])
  kind?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2048)
  mediaUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  mediaMimeType?: string;

  @IsOptional()
  @IsString()
  @MaxLength(191)
  replyToMessageId?: string;
}
