import { IsNotEmpty, IsString } from 'class-validator';

export class ApproveMessageRequestDto {
  @IsString()
  @IsNotEmpty()
  threadId!: string;
}
