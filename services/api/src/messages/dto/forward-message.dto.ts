import { ArrayMaxSize, ArrayMinSize, IsArray, IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class ForwardMessageDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(191)
  fromThreadId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(191)
  messageId!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(32)
  @IsString({ each: true })
  targetThreadIds!: string[];
}
