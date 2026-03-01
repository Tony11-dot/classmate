import 'package:flutter/foundation.dart';

@immutable
class SolutionImage {
  const SolutionImage({
    required this.id,
    required this.storagePath,
    required this.url,
    required this.mime,
    required this.kind,
    required this.width,
    required this.height,
  });

  final String id;
  final String storagePath;
  final String url;
  final String mime;
  final String kind;
  final int? width;
  final int? height;

  factory SolutionImage.fromJson(Map<String, dynamic> j) => SolutionImage(
        id: (j['id'] ?? '').toString(),
        storagePath: (j['storagePath'] ?? '').toString(),
        url: (j['url'] ?? '').toString(),
        mime: (j['mime'] ?? '').toString(),
        kind: (j['kind'] ?? '').toString(),
        width: j['width'] is num ? (j['width'] as num).toInt() : null,
        height: j['height'] is num ? (j['height'] as num).toInt() : null,
      );
}

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
    required this.createdAt,
    required this.images,
  });

  final String id;
  final String subject;
  final String sourceType;
  final String sourceName;
  final int? page;
  final String questionNumber;
  final String? title;
  final String? body;
  final DateTime? createdAt;
  final List<SolutionImage> images;

  factory Solution.fromJson(Map<String, dynamic> j) => Solution(
        id: (j['id'] ?? '').toString(),
        subject: (j['subject'] ?? '').toString(),
        sourceType: (j['sourceType'] ?? '').toString(),
        sourceName: (j['sourceName'] ?? '').toString(),
        page: j['page'] is num ? (j['page'] as num).toInt() : null,
        questionNumber: (j['questionNumber'] ?? '').toString(),
        title: j['title'] == null ? null : (j['title']).toString(),
        body: j['body'] == null ? null : (j['body']).toString(),
        createdAt: j['createdAt'] == null
            ? null
            : DateTime.tryParse(j['createdAt'].toString()),
        images: (j['images'] is List)
            ? (j['images'] as List)
                .whereType<Map>()
                .map((e) => SolutionImage.fromJson(
                    e.map((k, v) => MapEntry(k.toString(), v))))
                .toList(growable: false)
            : const <SolutionImage>[],
      );
}

@immutable
class SolutionsFilters {
  const SolutionsFilters({
    this.subject,
    this.sourceType,
    this.sourceName,
    this.page,
    this.questionNumber,
  });

  final String? subject;
  final String? sourceType;
  final String? sourceName;
  final int? page;
  final String? questionNumber;

  Map<String, String> toQuery({int? limit, String? cursor}) {
    final q = <String, String>{};
    if (limit != null) q['limit'] = '$limit';
    if (cursor != null && cursor.isNotEmpty) q['cursor'] = cursor;

    if (subject != null && subject!.trim().isNotEmpty) q['subject'] = subject!;
    if (sourceType != null && sourceType!.trim().isNotEmpty) {
      q['sourceType'] = sourceType!;
    }
    if (sourceName != null && sourceName!.trim().isNotEmpty) {
      q['sourceName'] = sourceName!;
    }
    if (page != null) q['page'] = '$page';
    if (questionNumber != null && questionNumber!.trim().isNotEmpty) {
      q['questionNumber'] = questionNumber!;
    }
    return q;
  }

  SolutionsFilters copyWith({
    String? subject,
    String? sourceType,
    String? sourceName,
    int? page,
    String? questionNumber,
  }) {
    return SolutionsFilters(
      subject: subject ?? this.subject,
      sourceType: sourceType ?? this.sourceType,
      sourceName: sourceName ?? this.sourceName,
      page: page ?? this.page,
      questionNumber: questionNumber ?? this.questionNumber,
    );
  }
}
