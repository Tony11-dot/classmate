import { IsBooleanString, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class NotificationsQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;

  // cursor = notification id (opaque to client)
  @IsOptional()
  @IsString()
  cursor?: string;

  // "true" => only unseen
  @IsOptional()
  @IsBooleanString()
  unseenOnly?: string;
}
