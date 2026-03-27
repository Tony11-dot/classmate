import { IsString, MaxLength } from 'class-validator';

export class MarkThreadReadDto {
  @IsString()
  @MaxLength(191)
  threadId!: string;
}
