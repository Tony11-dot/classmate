import { IsArray, IsBoolean, IsOptional, IsString } from 'class-validator';

export class CreateDmThreadDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsArray()
  participantIds!: string[];

  @IsOptional()
  @IsBoolean()
  isGroup?: boolean;
}
