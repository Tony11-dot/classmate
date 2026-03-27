import { IsNotEmpty, IsString } from 'class-validator';

export class MarkThreadReadDto {
  @IsString()
  @IsNotEmpty()
  threadId!: string;
}
