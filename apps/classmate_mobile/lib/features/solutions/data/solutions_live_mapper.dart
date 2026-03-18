import '../domain/solutions_models.dart';

class SolutionsLiveMapper {
  static List<QuestionSolutionCard> mapUploads(
    Object? raw, {
    required List<SolutionSubject> subjects,
  }) {
    final list = raw is List ? raw : const <dynamic>[];
    return list
        .whereType<Map>()
        .map(
          (e) =>
              _mapUpload(e.map((k, v) => MapEntry(k.toString(), v)), subjects),
        )
        .whereType<QuestionSolutionCard>()
        .toList(growable: false);
  }

  static QuestionSolutionCard? _mapUpload(
    Map<String, dynamic> json,
    List<SolutionSubject> subjects,
  ) {
    final book = json['book'] is Map
        ? (json['book'] as Map).map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};

    final filesRaw = json['files'] is List
        ? json['files'] as List
        : const <dynamic>[];
    final files = filesRaw
        .whereType<Map>()
        .map((e) {
          final f = e.map((k, v) => MapEntry(k.toString(), v));
          final kindRaw = '${f['kind'] ?? 'image'}'.toLowerCase();
          final kind = kindRaw == 'pdf'
              ? SolutionAssetKind.pdf
              : SolutionAssetKind.image;
          return SolutionUploadAsset(
            id: '${f['id'] ?? ''}',
            name: '${f['fileName'] ?? f['url'] ?? 'file'}',
            kind: kind,
          );
        })
        .toList(growable: false);

    final subjectTitle = '${json['subject'] ?? ''}'.trim();
    final matchedSubject = subjects
        .where(
          (s) => s.title == subjectTitle || s.id == subjectTitle.toLowerCase(),
        )
        .cast<SolutionSubject?>()
        .firstWhere((e) => e != null, orElse: () => null);
    final bookTitle = '${book['title'] ?? ''}'.trim();
    final matchedBook = matchedSubject?.books
        .where((b) => b.title == bookTitle)
        .cast<SolutionBook?>()
        .firstWhere((e) => e != null, orElse: () => null);

    final verificationStatus = '${json['verificationStatus'] ?? 'UNCHECKED'}'
        .toUpperCase();
    final moderationStatus = '${json['moderationStatus'] ?? 'PENDING'}'
        .toUpperCase();

    return QuestionSolutionCard(
      id: '${json['id'] ?? ''}',
      uploaderName: '${json['uploaderName'] ?? 'Classmate user'}',
      uploaderInitials: '${json['uploaderInitials'] ?? 'CM'}',
      subjectId: matchedSubject?.id ?? subjectTitle.toLowerCase(),
      bookId: matchedBook?.id ?? '${book['id'] ?? bookTitle}',
      pageNumber: '${json['pageNumber'] ?? ''}',
      questionNumber: '${json['questionNumber'] ?? ''}',
      caption: '${json['caption'] ?? ''}'.trim().isEmpty
          ? 'Shared solution from a classmate.'
          : '${json['caption']}',
      verifiedByNova:
          moderationStatus == 'APPROVED' && verificationStatus == 'VERIFIED',
      assets: files,
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
    );
  }
}
