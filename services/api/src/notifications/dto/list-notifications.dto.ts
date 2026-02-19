import { IsIn, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { Transform } from 'class-transformer';

export class ListNotificationsDto {
  @IsOptional()
  @Transform(({ value }) => (value === undefined ? undefined : Number(value)))
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 30;

  @IsOptional()
  @IsString()
  cursor?: string;

  @IsOptional()
  @IsIn(['all', 'seen', 'unseen'])
  state?: 'all' | 'seen' | 'unseen' = 'all';
}
