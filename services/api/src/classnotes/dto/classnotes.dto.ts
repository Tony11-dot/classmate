import { Type } from 'class-transformer';
import {
  IsArray,
  IsDateString,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
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

/// PATCH /classnotes/notebooks/:id — an edit made from the ClassMate ClassNotes
/// tab (rename, re-shelve, recolour). Every field is optional: only what's sent
/// changes. Marks the row `remoteEditedAt` so the native app pulls it instead of
/// pushing over it.
export class NotebookPatchDto {
  @IsOptional()
  @IsString()
  @MaxLength(300)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  coverColorHex?: string;

  /// `null` unfiles the notebook; omitted leaves its shelf alone.
  @IsOptional()
  @IsString()
  shelfId?: string | null;
}

/// PUT /classnotes/notebooks/order — the notebook ids in the order the user
/// dragged them into. Ids not listed keep their place after the listed ones.
export class NotebookOrderDto {
  @IsArray()
  @IsString({ each: true })
  ids!: string[];
}

/// POST /classnotes/changes/ack — the ids the native app has finished applying
/// locally, so their tombstones can be purged and their remote-edit marks cleared.
export class ChangesAckDto {
  @IsArray()
  @IsString({ each: true })
  ids!: string[];
}

/// One playable / openable thing on a page, uploaded alongside the rendered
/// image so the ClassNotes tab can listen to voice notes and open files and
/// links instead of just looking at a flat picture of the page.
///
/// `kind` is `audio`, `file` or `link`. Audio and files carry a data URL; links
/// carry their address. `dataUrl` has no MaxLength for the same reason as the
/// page render — the global JSON body limit bounds the request.
export class ClassNotesAttachmentDto {
  // audio | file | link
  @IsString()
  @MaxLength(16)
  kind!: string;

  @IsString()
  @MaxLength(300)
  name!: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  durationSeconds?: number;

  @IsOptional()
  @IsString()
  dataUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  url?: string;
}

/// One rendered page in a notebook-pages upload. `dataUrl` is a
/// `data:image/png;base64,...` string and can be large, so it has no
/// MaxLength — the global JSON body limit (see main.ts) bounds the request.
export class ClassNotesPageDto {
  @IsInt()
  @Min(0)
  pageIndex!: number;

  @IsString()
  dataUrl!: string;

  /// The page's voice notes, files and links. Omitted by older clients.
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ClassNotesAttachmentDto)
  attachments?: ClassNotesAttachmentDto[];
}

/// PUT /classnotes/notebooks/:id/pages body. `pages` is the set of rendered
/// pages to upsert; `pageCount` is the notebook's current page count so the
/// server can prune any rows at pageIndex >= pageCount (removed pages).
export class NotebookPagesUpsertDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ClassNotesPageDto)
  pages!: ClassNotesPageDto[];

  @IsInt()
  @Min(0)
  pageCount!: number;
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
