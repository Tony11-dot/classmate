import { IsIn } from 'class-validator';

export class RespondDmRequestDto {
  @IsIn(['accept', 'block'])
  action!: 'accept' | 'block';
}
