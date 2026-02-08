import { IsIn, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class AddSolutionImageDto {
  @IsString()
  url!: string;

  @IsString()
  storagePath!: string;

  @IsIn(['image', 'pdf', 'other'])
  kind!: 'image' | 'pdf' | 'other';

  @IsString()
  mime!: string;

  @IsInt()
  @Min(0)
  sizeBytes!: number;

  @IsOptional()
  @IsInt()
  width?: number;

  @IsOptional()
  @IsInt()
  height?: number;
}
