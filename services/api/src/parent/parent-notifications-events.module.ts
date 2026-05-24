import { Module } from '@nestjs/common';
import { ParentNotificationsEvents } from './parent-notifications.events';

/// Thin module exposing ONLY the parent-notifications RxJS Subject so
/// every other module can subscribe to the same singleton without
/// creating its own (two providers = two Subjects = events emitted by
/// one would never reach a subscriber on the other).
///
/// The parent SSE controller subscribes to this Subject; the
/// NotificationsHubService publishes to it when a parent notification
/// is created. They must share the same instance — that's what this
/// module exists to guarantee.
@Module({
  providers: [ParentNotificationsEvents],
  exports: [ParentNotificationsEvents],
})
export class ParentNotificationsEventsModule {}
