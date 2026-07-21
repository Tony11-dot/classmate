import { Injectable } from '@nestjs/common';
import { Response } from 'express';

export type RealtimeEvent =
  | { type: 'classroom_message'; classroomId: string }
  | { type: 'dm_message'; threadId: string }
  | { type: 'dm_read'; threadId: string }
  // Device-level receipt (second grey tick), as opposed to dm_read (blue).
  | { type: 'dm_delivered'; threadId: string }
  | { type: 'dm_typing'; threadId: string; userId: string }
  | { type: 'notification'; userId: string }
  | { type: 'grade_updated'; studentId: string }
  | { type: 'assignment_returned'; assignmentId: string; studentId: string }
  | { type: 'assignment_created'; classroomId?: string; targetUserIds?: string[] }
  | { type: 'material_created'; classroomId?: string; targetUserIds?: string[] }
  | { type: 'meeting_created'; classroomId?: string; targetUserIds?: string[] }
  | { type: 'schedule_updated'; studentId: string }
  | { type: 'ping' };

@Injectable()
export class RealtimeService {
  // userId → set of SSE responses
  private readonly connections = new Map<string, Set<Response>>();

  subscribe(userId: string, res: Response): () => void {
    if (!this.connections.has(userId)) {
      this.connections.set(userId, new Set());
    }
    this.connections.get(userId)!.add(res);

    // Keep-alive ping every 25s so proxies don't close idle connections
    const pingInterval = setInterval(() => {
      this.send(res, { type: 'ping' });
    }, 25_000);

    const unsubscribe = () => {
      clearInterval(pingInterval);
      try { res.removeListener('error', onError); } catch (_) {}
      try { res.removeListener('close', unsubscribe); } catch (_) {}
      const set = this.connections.get(userId);
      if (set) {
        set.delete(res);
        if (set.size === 0) this.connections.delete(userId);
      }
    };

    // Clean up on write error or abrupt network drop so connections don't leak
    const onError = () => unsubscribe();
    try { res.on('error', onError); } catch (_) {}
    try { res.on('close', unsubscribe); } catch (_) {}

    return unsubscribe;
  }

  private send(res: Response, event: RealtimeEvent) {
    try {
      res.write(`data: ${JSON.stringify(event)}\n\n`);
    } catch (_) {}
  }

  /** Emit to a specific user. */
  emitToUser(userId: string, event: RealtimeEvent) {
    const set = this.connections.get(userId);
    if (!set) return;
    for (const res of set) this.send(res, event);
  }

  /** Emit to a list of users. */
  emitToUsers(userIds: string[], event: RealtimeEvent) {
    for (const id of userIds) this.emitToUser(id, event);
  }

  get connectedUserCount() {
    return this.connections.size;
  }
}
