import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateDirectRequestDto {
  @IsString()
  @IsNotEmpty()
  recipientUserId!: string;

  @IsString()
  @IsOptional()
  firstMessage?: string;
}
