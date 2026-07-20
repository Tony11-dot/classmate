import {
  ArrayMaxSize,
  IsArray,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class SupportTurnDto {
  @IsIn(['user', 'assistant'])
  role!: 'user' | 'assistant';

  @IsString()
  @MaxLength(2000)
  content!: string;
}

export class AskSupportDto {
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  question!: string;

  /// Prior turns for follow-up context. Capped small — this is a support
  /// helper, not a long-form chat. The service trims further defensively.
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(16)
  @ValidateNested({ each: true })
  @Type(() => SupportTurnDto)
  history?: SupportTurnDto[];
}
