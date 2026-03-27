import { IsIn, IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class DeleteMessageDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(191)
  threadId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(191)
  messageId!: string;

  @IsOptional()
  @IsString()
  @IsIn(['deleteForMe', 'deleteForEveryone'])
  mode?: string;
}
