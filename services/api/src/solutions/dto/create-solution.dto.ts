import { IsInt, IsOptional, IsString } from 'class-validator';

export class CreateSolutionDto {
  @IsString()
  subject!: string;

  @IsString()
  sourceType!: string;

  @IsString()
  sourceName!: string;

  @IsInt()
  page!: number;

  @IsOptional()
  @IsString()
  questionNumber?: string;

  @IsOptional()
  @IsString()
  body?: string;
}
