import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CreateDirectRequestDto {
  @IsString()
  @IsNotEmpty()
  recipientUserId!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(4000)
  firstMessage!: string;
}
