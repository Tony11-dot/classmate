import { IsDefined, IsInt, IsString, Max, Min } from 'class-validator';

export class OnboardStudentDto {
  @IsString()
  cohortId!: string;

  @IsString()
  joinCode!: string;

  @IsDefined()

  @IsInt()
  @Min(1)
  @Max(5)
  englishLevel!: number;

  @IsDefined()

  @IsInt()
  @Min(1)
  @Max(5)
  mathLevel!: number;
}
