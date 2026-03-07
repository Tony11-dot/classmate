export type OutboxEventType =
  | 'solution.created'
  | 'solution.liked'
  | 'solution.unliked'
  | 'solution.commented'
  | 'solution.reposted'
  | 'classroom.message.created'
  | 'assignment.created'
  | 'grade.posted'
  | 'notification.created';

export type OutboxEventPayload = Record<string, unknown>;
