class Solution {
  Solution({
    required this.id,
    required this.subject,
    required this.sourceType,
    required this.sourceName,
    required this.page,
    required this.questionNumber,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.images,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  final String id;
  final String subject;
  final String sourceType;
  final String sourceName;
  final int? page;
  final String? questionNumber;
  final String? title;
  final String? body;
  final int likeCount;
  final int commentCount;
  final String? createdAt;
  final List<Map<String, dynamic>> images;

  factory Solution.fromJson(Map<String, dynamic> j) => Solution(
    id: (j['id'] ?? '').toString(),
    subject: (j['subject'] ?? '').toString(),
    sourceType: (j['sourceType'] ?? '').toString(),
    sourceName: (j['sourceName'] ?? '').toString(),
    page: (j['page'] is int)
        ? j['page'] as int
        : (j['page'] == null ? null : int.tryParse(j['page'].toString())),
    questionNumber: j['questionNumber']?.toString(),
    title: j['title']?.toString(),
    body: j['body']?.toString(),
    createdAt: j['createdAt']?.toString(),
    images: (j['images'] is List)
        ? (j['images'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : const <Map<String, dynamic>>[],
    likeCount: (j['likeCount'] is int)
        ? j['likeCount'] as int
        : int.tryParse((j['likeCount'] ?? 0).toString()) ?? 0,
    commentCount: (j['commentCount'] is int)
        ? j['commentCount'] as int
        : int.tryParse((j['commentCount'] ?? 0).toString()) ?? 0,
  );
}

class SolutionsPage {
  SolutionsPage({required this.items, required this.nextCursor});
  final List<Solution> items;
  final String? nextCursor;

  factory SolutionsPage.fromJson(Map<String, dynamic> j) => SolutionsPage(
    items: (j['items'] is List)
        ? (j['items'] as List)
              .whereType<Map>()
              .map((e) => Solution.fromJson(Map<String, dynamic>.from(e)))
              .toList()
        : const <Solution>[],
    nextCursor: j['nextCursor']?.toString(),
  );
}
