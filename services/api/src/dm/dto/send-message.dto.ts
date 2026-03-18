export class SendDmMessageDto {
  kind!: 'TEXT' | 'IMAGE' | 'VOICE';
  text?: string;
  mediaUrl?: string;
  mediaMimeType?: string;
  mediaMode?: 'ONCE' | 'REPLAY' | 'KEEP';
}
