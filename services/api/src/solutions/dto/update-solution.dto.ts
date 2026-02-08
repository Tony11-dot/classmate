import { IsInt, IsOptional, IsString } from 'class-validator';

export class UpdateSolutionDto {
  @IsOptional()
  @IsString()
  subject?: string;

  @IsOptional()
  @IsString()
  sourceType?: string;

  @IsOptional()
  @IsString()
  sourceName?: string;

  @IsOptional()
  @IsInt()
  page?: number;

  @IsOptional()
  @IsString()
  questionNumber?: string;

  @IsOptional()
  @IsString()
  body?: string;
}
