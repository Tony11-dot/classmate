/// A typed target for a forward operation.
///
/// Returned by `showForwardTargetPicker` so the caller can disambiguate
/// between forwarding into a DM thread and a classroom chat.
sealed class ForwardTarget {
  const ForwardTarget();

  /// The underlying thread/course id.
  String get id;
}

class ForwardTargetDm extends ForwardTarget {
  const ForwardTargetDm(this.threadId);

  final String threadId;

  @override
  String get id => threadId;

  @override
  bool operator ==(Object other) =>
      other is ForwardTargetDm && other.threadId == threadId;

  @override
  int get hashCode => Object.hash('dm', threadId);
}

class ForwardTargetClassroom extends ForwardTarget {
  const ForwardTargetClassroom(this.courseId);

  final String courseId;

  @override
  String get id => courseId;

  @override
  bool operator ==(Object other) =>
      other is ForwardTargetClassroom && other.courseId == courseId;

  @override
  int get hashCode => Object.hash('classroom', courseId);
}
