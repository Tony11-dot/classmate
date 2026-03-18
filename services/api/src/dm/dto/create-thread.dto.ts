export class CreateDmThreadDto {
  title?: string;
  participantIds!: string[];
  isGroup?: boolean;
}
