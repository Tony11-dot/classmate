import {
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  Max,
  ValidateNested,
  ArrayMaxSize,
  ArrayMinSize,
} from 'class-validator';
import { Type } from 'class-transformer';

export class FormulaComponentDto {
  @IsString()
  @MaxLength(64)
  assessmentId!: string;

  @IsInt()
  @Min(0)
  @Max(100)
  weight!: number;
}

export class FormulaVariantDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  label?: string;

  @IsOptional()
  @IsInt()
  sortOrder?: number;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(40)
  @ValidateNested({ each: true })
  @Type(() => FormulaComponentDto)
  components!: FormulaComponentDto[];
}

export class CreateGradeFormulaDto {
  @IsString()
  @MaxLength(120)
  title!: string;

  @IsString()
  @MaxLength(64)
  cohortId!: string;

  @IsString()
  @MaxLength(160)
  subject!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  units?: number;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(20)
  @ValidateNested({ each: true })
  @Type(() => FormulaVariantDto)
  variants!: FormulaVariantDto[];
}

export class UpdateGradeFormulaDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  title?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  units?: number;

  @IsOptional()
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(20)
  @ValidateNested({ each: true })
  @Type(() => FormulaVariantDto)
  variants?: FormulaVariantDto[];
}
