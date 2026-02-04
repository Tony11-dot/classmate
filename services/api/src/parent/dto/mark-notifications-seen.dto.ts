import { ArrayMaxSize, IsArray, IsOptional, IsString } from 'class-validator';

export class MarkNotificationsSeenDto {
  // mark specific notification ids as seen
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(500)
  @IsString({ each: true })
  ids?: string[];
}
