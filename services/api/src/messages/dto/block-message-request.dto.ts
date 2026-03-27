import { IsNotEmpty, IsString } from 'class-validator';

export class BlockMessageRequestDto {
  @IsString()
  @IsNotEmpty()
  threadId!: string;
}
