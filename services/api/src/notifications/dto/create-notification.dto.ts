import { IsIn, IsObject, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateNotificationDto {
  @IsString()
  @MaxLength(64)
  type!: string;

  @IsString()
  @MaxLength(140)
  title!: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  body?: string;

  @IsOptional()
  @IsObject()
  data?: Record<string, any>;

  @IsOptional()
  @IsIn(['info', 'success', 'warning', 'error'])
  severity?: 'info' | 'success' | 'warning' | 'error' = 'info';
}
