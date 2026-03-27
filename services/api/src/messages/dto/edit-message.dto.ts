import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class EditMessageDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(191)
  threadId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(191)
  messageId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(4000)
  text!: string;
}
