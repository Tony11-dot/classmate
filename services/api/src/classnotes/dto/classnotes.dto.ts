import {
  IsDateString,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';

/// Upsert payload for one notebook (the id travels in the URL, not the body).
/// Mirrors the native ClassNotes `Notebook` value fields. Global validation is
/// `forbidNonWhitelisted`, so every accepted field must be declared here.
export class NotebookUpsertDto {
  @IsString()
  @MaxLength(300)
  title!: string;

  @IsString()
  @MaxLength(20)
  coverColorHex!: string;

  // PageTemplate.rawValue — blank | ruled | grid | dotGrid.
  @IsString()
  @MaxLength(16)
  template!: string;

  // null / omitted = unfiled (no shelf).
  @IsOptional()
  @IsString()
  shelfId?: string | null;

  @IsInt()
  @Min(0)
  pageCount!: number;

  @IsDateString()
  createdAt!: string;

  @IsDateString()
  updatedAt!: string;
}

/// One prior turn of NOVA note-chat.
export class AiTurnDto {
  @IsString()
  @MaxLength(20)
  role!: string;

  @IsString()
  @MaxLength(4000)
  content!: string;
}

/// NOVA note-assistant request. `task` selects the behaviour; `text` is the
/// student's OCR'd note (beautify/explain) or their question (chat).
export class NotesAiDto {
  // beautify | explain | chat
  @IsString()
  @MaxLength(16)
  task!: string;

  @IsString()
  @MaxLength(6000)
  text!: string;

  // Optional page context for chat (the OCR of the note they're looking at).
  @IsOptional()
  @IsString()
  @MaxLength(6000)
  pageContext?: string;

  @IsOptional()
  history?: AiTurnDto[];
}

/// Upsert payload for one shelf (id in the URL). Mirrors native `Shelf`.
export class ShelfUpsertDto {
  @IsString()
  @MaxLength(200)
  name!: string;

  @IsString()
  @MaxLength(20)
  colorHex!: string;

  // SF Symbol name from the native app (mapped to an icon on the client).
  @IsString()
  @MaxLength(60)
  symbolName!: string;

  @IsInt()
  @Min(0)
  sortIndex!: number;

  @IsDateString()
  createdAt!: string;
}
