import { IsBooleanString, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class NotificationsQueryDto {
  @IsOptional()
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
