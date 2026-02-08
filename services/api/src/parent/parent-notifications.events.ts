import { Injectable } from '@nestjs/common';
import { Subject } from 'rxjs';

export type ParentNotifEvent =
  | { type: 'notification.created'; parentId: string }
  | { type: 'notification.seen'; parentId: string; ids: string[] }
  | { type: 'unread.count'; parentId: string };

@Injectable()
export class ParentNotificationsEvents {
  private readonly subject = new Subject<ParentNotifEvent>();
  readonly events$ = this.subject.asObservable();

  emit(evt: ParentNotifEvent) {
    this.subject.next(evt);
  }
}
