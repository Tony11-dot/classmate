import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsNotEmpty,
  IsString,
  MaxLength,
} from 'class-validator';

export class CreateGroupThreadDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  title!: string;

  @IsArray()
  @ArrayMinSize(2)
  @ArrayMaxSize(128)
  @IsString({ each: true })
  memberIds!: string[];
}
