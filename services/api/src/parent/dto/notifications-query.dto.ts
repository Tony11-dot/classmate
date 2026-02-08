import { IsBoolean, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { Transform, Type } from 'class-transformer';

export class NotificationsQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  take?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;

  @IsOptional()
  @IsString()
  cursor?: string;

  @IsOptional()
  @Transform(({ value }) => {
    if (Array.isArray(value)) value = value[0];
    if (value === true || value === false) return value;
    if (typeof value === 'number') return value !== 0;
    if (typeof value === 'string') {
      const v = value.trim().toLowerCase();
      if (v === 'true' || v === '1' || v === 'yes' || v === 'y') return true;
      if (v === 'false' || v === '0' || v === 'no' || v === 'n') return false;
    }
    return undefined;
  })
  @IsBoolean()
  unseenOnly?: boolean;

  @IsOptional()
  @IsString()
  studentId?: string;
}
