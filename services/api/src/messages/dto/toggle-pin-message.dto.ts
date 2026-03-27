import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class TogglePinMessageDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(191)
  threadId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(191)
  messageId!: string;
}
