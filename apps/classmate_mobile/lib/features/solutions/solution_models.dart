class SolutionUser {
  final String id;
  final String fullName;
  final String username;

  const SolutionUser({
    required this.id,
    required this.fullName,
    required this.username,
  });

  static SolutionUser? fromJson(dynamic json) {
    if (json is! Map) return null;
    return SolutionUser(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
    );
  }
}

class SolutionSubject {
  final String id;
  final String name;

  const SolutionSubject({required this.id, required this.name});

  static SolutionSubject? fromJson(dynamic json) {
    if (json is! Map) return null;
    return SolutionSubject(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class SolutionCounts {
  final int likes;
  final int comments;

  const SolutionCounts({required this.likes, required this.comments});

  static SolutionCounts fromJson(dynamic json) {
    if (json is! Map) return const SolutionCounts(likes: 0, comments: 0);
    return SolutionCounts(
      likes: (json['likes'] is int)
          ? json['likes'] as int
          : int.tryParse('${json['likes']}') ?? 0,
      comments: (json['comments'] is int)
          ? json['comments'] as int
          : int.tryParse('${json['comments']}') ?? 0,
    );
  }
}

class SolutionItem {
  final String id;
  final String userId;
  final String subjectId;
  final int grade;
  final String book;
  final int page;
  final String question;
  final String? caption;
  final String mediaUrl;
  final DateTime createdAt;

  final SolutionUser? user;
  final SolutionSubject? subject;
  final SolutionCounts counts;

  const SolutionItem({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.grade,
    required this.book,
    required this.page,
    required this.question,
    required this.mediaUrl,
    required this.createdAt,
    this.caption,
    this.user,
    this.subject,
    required this.counts,
  });

  static SolutionItem fromJson(dynamic json) {
    if (json is! Map) {
      throw ArgumentError('SolutionItem.fromJson expected Map');
    }

    return SolutionItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      subjectId: (json['subjectId'] ?? '').toString(),
      grade: (json['grade'] is int)
          ? json['grade'] as int
          : int.tryParse('${json['grade']}') ?? 0,
      book: (json['book'] ?? '').toString(),
      page: (json['page'] is int)
          ? json['page'] as int
          : int.tryParse('${json['page']}') ?? 0,
      question: (json['question'] ?? '').toString(),
      caption: (json['caption'] == null) ? null : json['caption'].toString(),
      mediaUrl: (json['mediaUrl'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      user: SolutionUser.fromJson(json['_user'] ?? json['user'] ?? {}),
      subject: SolutionSubject.fromJson(
        json['_subject'] ?? json['subject'] ?? {},
      ),
      counts: SolutionCounts.fromJson(json['_count'] ?? const {}),
    );
  }
}
