import {
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class ReactMessageDto {
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
  emoji?: string;
}
