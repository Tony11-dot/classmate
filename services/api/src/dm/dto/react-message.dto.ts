import { IsString, MaxLength } from 'class-validator';

export class ReactDmMessageDto {
  @IsString()
  @MaxLength(16)
  emoji!: string;
}
