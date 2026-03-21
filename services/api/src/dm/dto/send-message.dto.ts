import { IsIn, IsOptional, IsString } from 'class-validator';

export class SendDmMessageDto {
  @IsOptional()
  @IsIn(['TEXT', 'IMAGE', 'VOICE', 'VIDEO', 'FILE'])
  kind?: 'TEXT' | 'IMAGE' | 'VOICE' | 'VIDEO' | 'FILE';

  @IsOptional()
  @IsString()
  text?: string;

  @IsOptional()
  @IsString()
  mediaUrl?: string;

  @IsOptional()
  @IsString()
  mediaMimeType?: string;

  @IsOptional()
  @IsString()
  mediaMode?: string;

  @IsOptional()
  @IsString()
  originalName?: string;

  @IsOptional()
  @IsString()
  uploadedPath?: string;
}
