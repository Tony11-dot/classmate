import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class SendMessageDto {
  @IsString()
  @IsNotEmpty()
  threadId!: string;

  @IsString()
  @IsOptional()
  @MaxLength(8000)
  text?: string;

  @IsString()
  @IsOptional()
  replyToMessageId?: string;
}
