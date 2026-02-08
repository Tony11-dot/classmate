import { IsInt, IsString, Max, Min } from 'class-validator';

export class OnboardStudentDto {
  @IsString()
  cohortId!: string;

  @IsString()
  joinCode!: string;

  @IsInt()
  @Min(1)
  @Max(5)
  englishLevel!: number;

  @IsInt()
  @Min(1)
  @Max(5)
  mathLevel!: number;
}
