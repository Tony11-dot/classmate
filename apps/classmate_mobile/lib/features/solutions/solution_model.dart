import 'package:flutter/foundation.dart';

@immutable
class Solution {
  const Solution({
    required this.id,
    required this.subject,
    required this.sourceType,
    required this.sourceName,
    required this.page,
    required this.questionNumber,
    required this.title,
    required this.body,
    required this.authorName,
    required this.createdAt,
    required this.images,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
  });

  final String id;
  final String subject;
  final String sourceType;
  final String sourceName;
  final int? page;
  final String? questionNumber;
  final String? title;
  final String? body;
  final String? authorName;
  final String? createdAt;
  final List<Map<String, dynamic>> images;

  final int likeCount;
  final int commentCount;
  final bool likedByMe;

  Solution copyWith({
    String? id,
    String? subject,
    String? sourceType,
    String? sourceName,
    int? page,
    String? questionNumber,
    String? title,
    String? body,
    String? authorName,
    String? createdAt,
    List<Map<String, dynamic>>? images,
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
  }) {
    return Solution(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      sourceType: sourceType ?? this.sourceType,
      sourceName: sourceName ?? this.sourceName,
      page: page ?? this.page,
      questionNumber: questionNumber ?? this.questionNumber,
      title: title ?? this.title,
      body: body ?? this.body,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }

  factory Solution.fromJson(Map<String, dynamic> j) => Solution(
    id: (j['id'] ?? '').toString(),
    subject: (j['subject'] ?? '').toString(),
    sourceType: (j['sourceType'] ?? '').toString(),
    sourceName: (j['sourceName'] ?? '').toString(),
    page: (j['page'] is int)
        ? j['page']
        : (j['page'] == null ? null : int.tryParse(j['page'].toString())),
    questionNumber: j['questionNumber']?.toString(),
    title: j['title']?.toString(),
    body: j['body']?.toString(),
    authorName: j['authorName']?.toString(),
    createdAt: j['createdAt']?.toString(),
    images: (j['images'] is List)
        ? (j['images'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(growable: false)
        : const <Map<String, dynamic>>[],
    likeCount: (j['likeCount'] is int)
        ? j['likeCount']
        : int.tryParse((j['likeCount'] ?? 0).toString()) ?? 0,
    commentCount: (j['commentCount'] is int)
        ? j['commentCount']
        : int.tryParse((j['commentCount'] ?? 0).toString()) ?? 0,
    likedByMe: (j['likedByMe'] is bool)
        ? j['likedByMe'] as bool
        : (j['likedByMe']?.toString() == 'true'),
  );
}

@immutable
class SolutionsPage {
  const SolutionsPage({required this.items, required this.nextCursor});
  final List<Solution> items;
  final String? nextCursor;

  factory SolutionsPage.fromJson(Map<String, dynamic> j) => SolutionsPage(
    items: (j['items'] is List)
        ? (j['items'] as List)
              .whereType<Map>()
              .map((e) => Solution.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
        : const <Solution>[],
    nextCursor: j['nextCursor']?.toString(),
  );
}

@immutable
class SolutionAuthor {
  const SolutionAuthor({required this.id, required this.name});
  final String id;
  final String name;

  factory SolutionAuthor.fromJson(Map<String, dynamic> j) => SolutionAuthor(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
  );
}

@immutable
class SolutionComment {
  const SolutionComment({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.authorId,
    required this.author,
  });

  final String id;
  final String body;
  final String createdAt;
  final String authorId;
  final SolutionAuthor author;

  factory SolutionComment.fromJson(Map<String, dynamic> j) => SolutionComment(
    id: (j['id'] ?? '').toString(),
    body: (j['body'] ?? '').toString(),
    createdAt: (j['createdAt'] ?? '').toString(),
    authorId: (j['authorId'] ?? '').toString(),
    author: SolutionAuthor.fromJson(
      Map<String, dynamic>.from((j['author'] as Map?) ?? const {}),
    ),
  );
}

@immutable
class SolutionCommentsPage {
  const SolutionCommentsPage({required this.items, required this.nextCursor});
  final List<SolutionComment> items;
  final String? nextCursor;

  factory SolutionCommentsPage.fromJson(Map<String, dynamic> j) =>
      SolutionCommentsPage(
        items: (j['items'] is List)
            ? (j['items'] as List)
                  .whereType<Map>()
                  .map(
                    (e) =>
                        SolutionComment.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList(growable: false)
            : const <SolutionComment>[],
        nextCursor: j['nextCursor']?.toString(),
      );
}
